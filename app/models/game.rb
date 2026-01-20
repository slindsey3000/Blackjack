# frozen_string_literal: true

class Game < ApplicationRecord
  MAX_PLAYERS = 6

  has_many :players, -> { order(:position) }, dependent: :destroy

  # Game statuses
  STATUSES = %w[waiting dealing playing dealer_turn finished].freeze

  validates :status, inclusion: { in: STATUSES }

  # Scopes
  scope :active, -> { where.not(status: "finished") }

  # Initialize a new game with a shuffled shoe
  after_initialize :initialize_shoe, if: :new_record?

  def initialize_shoe
    self.shoe_cards = Shoe.new.to_a if shoe_cards.blank?
    self.revealed_cards = [] if revealed_cards.nil?
  end

  # Get the shoe object
  def shoe
    @shoe ||= Shoe.from_a(shoe_cards)
  end

  # Persist shoe changes
  def save_shoe!
    self.shoe_cards = shoe.to_a
    save!
  end

  # Get the dealer
  def dealer
    players.find_by(is_dealer: true)
  end

  # Get non-dealer players in position order
  def active_players
    players.where(is_dealer: false).order(:position)
  end

  # Get the current player whose turn it is
  def current_player
    active_players.find_by(position: current_player_position)
  end

  # Can we add more players?
  def can_add_player?
    status == "waiting" && active_players.count < MAX_PLAYERS
  end

  # Get next available position for a new player
  def next_available_position
    taken = active_players.pluck(:position)
    (0...MAX_PLAYERS).find { |pos| !taken.include?(pos) }
  end

  # Add a card to revealed cards (for counting)
  def reveal_card(card)
    card_hash = card.is_a?(Card) ? card.to_h : card
    self.revealed_cards = (revealed_cards || []) + [card_hash]
  end

  # Check if game is in a playable state
  def playing?
    status == "playing"
  end

  def waiting?
    status == "waiting"
  end

  def finished?
    status == "finished"
  end

  def dealer_turn?
    status == "dealer_turn"
  end
end
