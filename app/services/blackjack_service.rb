# frozen_string_literal: true

# Main service for handling Blackjack game logic
class BlackjackService
  attr_reader :game

  def initialize(game)
    @game = game
  end

  # Create a new game with a human player and dealer
  def self.create_game(player_name: "Player")
    game = Game.create!(status: "waiting")

    # Create the dealer (position -1, always present)
    game.players.create!(
      name: "Dealer",
      is_dealer: true,
      is_computer: true,
      position: -1,
      status: "waiting"
    )

    # Create the human player
    game.players.create!(
      name: player_name,
      is_dealer: false,
      is_computer: false,
      position: 0,
      status: "waiting"
    )

    game
  end

  # Add a computer player to the game
  def add_computer_player(skill_level:)
    return { success: false, error: "Cannot add player" } unless game.can_add_player?

    position = game.next_available_position
    return { success: false, error: "Table is full" } if position.nil?

    skill_index = skill_level.is_a?(Symbol) ? Player.skill_levels[skill_level] : skill_level.to_i
    skill_name = %w[low medium high][skill_index] || skill_level.to_s
    player = game.players.create!(
      name: "CPU #{position + 1} (#{skill_name.capitalize})",
      is_dealer: false,
      is_computer: true,
      skill_level: skill_level,
      position: position,
      status: "waiting"
    )

    { success: true, player: player }
  end

  # Start a new round - deal initial cards
  def deal_round
    return { success: false, error: "Game not in waiting state" } unless game.waiting?
    return { success: false, error: "No players at table" } if game.active_players.empty?

    # Clear all hands and reset statuses
    game.players.each do |player|
      player.clear_hand!
      player.update!(status: "waiting", result: nil)
    end

    # Clear revealed cards for new round (set position to -1 so advance finds first player)
    game.update!(revealed_cards: [], current_player_position: -1)

    # Deal cards in correct order: one to each player, then dealer, repeat
    all_players = game.active_players.to_a
    dealer = game.dealer

    # First card to each player (face up)
    all_players.each do |player|
      deal_card_to(player, reveal: true)
    end

    # First card to dealer (face up - the "up card")
    deal_card_to(dealer, reveal: true)

    # Second card to each player (face up)
    all_players.each do |player|
      deal_card_to(player, reveal: true)
    end

    # Second card to dealer (face down - the "hole card")
    deal_card_to(dealer, reveal: false)

    # Check for naturals and set initial statuses
    check_naturals

    # Set game to playing and find first player to act
    game.update!(status: "dealing")
    advance_to_next_player

    game.save_shoe!
    { success: true }
  end

  # Player hits (takes another card)
  def hit(player)
    return { success: false, error: "Not your turn" } unless can_player_act?(player)

    card = deal_card_to(player, reveal: true)
    game.save_shoe!

    if player.busted?
      player.update!(status: "busted")
      advance_to_next_player
    end

    { success: true, card: card, busted: player.busted? }
  end

  # Player stands (ends their turn)
  def stand(player)
    return { success: false, error: "Not your turn" } unless can_player_act?(player)

    player.update!(status: "stood")
    advance_to_next_player

    { success: true }
  end

  # Play dealer's turn according to house rules
  def play_dealer_turn
    return { success: false, error: "Not dealer's turn" } unless game.dealer_turn?

    dealer = game.dealer

    # Reveal hole card
    if dealer.hole_card
      game.reveal_card(dealer.hole_card)
    end

    # Dealer must hit until 17 or higher
    # Dealer must hit on soft 17
    while should_dealer_hit?(dealer)
      deal_card_to(dealer, reveal: true)
    end

    if dealer.busted?
      dealer.update!(status: "busted")
    else
      dealer.update!(status: "stood")
    end

    game.save_shoe!

    # Determine winners
    determine_results

    game.update!(status: "finished")

    { success: true }
  end

  # Start a new round (reset for another hand)
  def new_round
    return { success: false, error: "Game not finished" } unless game.finished?

    # Check if shoe needs reshuffling
    if game.shoe.needs_reshuffle?
      game.shoe.reshuffle!
      game.update!(revealed_cards: [])
    end

    game.update!(status: "waiting")
    game.save_shoe!

    { success: true }
  end

  private

  def deal_card_to(player, reveal: true)
    card = game.shoe.deal
    player.add_card(card)
    player.save!

    game.reveal_card(card) if reveal

    card
  end

  def check_naturals
    # Check each player for blackjack
    game.active_players.each do |player|
      if player.blackjack?
        player.update!(status: "blackjack")
      else
        player.update!(status: "playing")
      end
    end

    # Check dealer for blackjack (peek if up card is A or 10-value)
    dealer = game.dealer
    if dealer.up_card&.ace? || dealer.up_card&.ten_card?
      if dealer.blackjack?
        dealer.update!(status: "blackjack")
      end
    end
  end

  def can_player_act?(player)
    game.playing? &&
      game.current_player_position == player.position &&
      player.can_act?
  end

  def advance_to_next_player
    # Find the next player who can act
    current_pos = game.current_player_position

    # Check remaining players in order
    remaining_players = game.active_players.where("position > ?", current_pos)
    next_player = remaining_players.find(&:can_act?)

    if next_player
      game.update!(current_player_position: next_player.position, status: "playing")
    else
      # No more players, move to dealer's turn
      game.update!(status: "dealer_turn")
    end
  end

  def should_dealer_hit?(dealer)
    value = dealer.hand_value
    return true if value < 17
    return true if value == 17 && dealer.soft_hand? # Hit on soft 17
    false
  end

  def determine_results
    dealer = game.dealer
    dealer_value = dealer.busted? ? 0 : dealer.hand_value
    dealer_blackjack = dealer.blackjack?

    game.active_players.each do |player|
      result = calculate_result(player, dealer_value, dealer_blackjack)
      player.update!(result: result)
    end
  end

  def calculate_result(player, dealer_value, dealer_blackjack)
    # Player busted = lose
    return "lose" if player.busted?

    player_value = player.hand_value
    player_blackjack = player.blackjack?

    # Both have blackjack = push
    return "push" if player_blackjack && dealer_blackjack

    # Player blackjack, dealer doesn't = blackjack win (pays 3:2)
    return "blackjack_win" if player_blackjack

    # Dealer blackjack, player doesn't = lose
    return "lose" if dealer_blackjack

    # Dealer busted = win
    return "win" if dealer_value == 0

    # Compare values
    if player_value > dealer_value
      "win"
    elsif player_value < dealer_value
      "lose"
    else
      "push"
    end
  end
end
