# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :set_game, only: [:show, :deal, :hit, :stand, :add_player, :new_round, :remove_player]

  def index
    @games = Game.active.order(created_at: :desc).limit(10)
  end

  def new
    # Just show the new game form
  end

  def create
    player_name = params[:player_name].presence || "Player"
    @game = BlackjackService.create_game(player_name: player_name)
    redirect_to @game
  end

  def show
    @service = BlackjackService.new(@game)
    @counting_service = CardCountingService.new(@game)

    # If it's a computer player's turn and game is playing, auto-play them
    auto_play_computer_players if @game.playing?
  end

  def deal
    service = BlackjackService.new(@game)
    result = service.deal_round

    if result[:success]
      redirect_to @game
    else
      redirect_to @game, alert: result[:error]
    end
  end

  def hit
    player = @game.current_player

    if player.nil? || !player.human?
      redirect_to @game, alert: "Not your turn"
      return
    end

    service = BlackjackService.new(@game)
    result = service.hit(player)

    # After human action, check if we need to play computer players or dealer
    handle_post_action

    redirect_to @game
  end

  def stand
    player = @game.current_player

    if player.nil? || !player.human?
      redirect_to @game, alert: "Not your turn"
      return
    end

    service = BlackjackService.new(@game)
    result = service.stand(player)

    # After human action, check if we need to play computer players or dealer
    handle_post_action

    redirect_to @game
  end

  def add_player
    skill_level = params[:skill_level].to_i

    service = BlackjackService.new(@game)
    result = service.add_computer_player(skill_level: skill_level)

    if result[:success]
      redirect_to @game, notice: "#{result[:player].name} joined the table"
    else
      redirect_to @game, alert: result[:error]
    end
  end

  def remove_player
    player = @game.players.find_by(id: params[:player_id])

    if player && player.is_computer? && @game.waiting?
      player.destroy
      redirect_to @game, notice: "Player removed"
    else
      redirect_to @game, alert: "Cannot remove this player"
    end
  end

  def new_round
    service = BlackjackService.new(@game)
    result = service.new_round

    if result[:success]
      redirect_to @game
    else
      redirect_to @game, alert: result[:error]
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def auto_play_computer_players
    service = BlackjackService.new(@game)

    loop do
      @game.reload
      break unless @game.playing?

      current = @game.current_player
      break if current.nil? || current.human?

      # Computer player's turn
      play_computer_turn(service, current)
    end

    # Check if we need to play dealer
    if @game.dealer_turn?
      service.play_dealer_turn
      @game.reload
    end
  end

  def play_computer_turn(service, player)
    dealer_up_card = @game.dealer&.up_card

    cpu_service = ComputerPlayerService.new(player, dealer_up_card)

    while player.can_act? && cpu_service.should_hit?
      service.hit(player)
      player.reload
    end

    # If still can act (didn't bust), stand
    if player.can_act?
      service.stand(player)
    end
  end

  def handle_post_action
    @game.reload
    auto_play_computer_players
  end
end
