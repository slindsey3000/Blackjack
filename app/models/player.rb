# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :game

  # Skill levels for computer players
  enum :skill_level, { low: 0, medium: 1, high: 2 }, prefix: true

  # Player statuses during a round
  STATUSES = %w[waiting playing stood busted blackjack].freeze

  # Results after round completion
  RESULTS = %w[win lose push blackjack_win].freeze

  validates :name, presence: true
  validates :position, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :result, inclusion: { in: RESULTS }, allow_nil: true
  validates :skill_level, presence: true, if: -> { is_computer? && !is_dealer? }

  # Scopes
  scope :humans, -> { where(is_computer: false, is_dealer: false) }
  scope :computers, -> { where(is_computer: true) }
  scope :dealers, -> { where(is_dealer: true) }
  scope :in_play, -> { where(status: %w[waiting playing]) }

  # Get the hand object
  def hand
    @hand ||= Hand.from_a(hand_cards)
  end

  # Clear cached hand (call after updating hand_cards)
  def reload_hand!
    @hand = nil
  end

  # Add a card to the player's hand
  def add_card(card)
    hand.add_card(card)
    self.hand_cards = hand.to_a
    card
  end

  # Clear the hand for a new round
  def clear_hand!
    self.hand_cards = []
    @hand = nil
  end

  # Hand value helpers
  def hand_value
    hand.best_value
  end

  def busted?
    hand.busted?
  end

  def blackjack?
    hand.blackjack?
  end

  def soft_hand?
    hand.soft?
  end

  # Status helpers
  def can_act?
    status == "playing" && !busted? && !blackjack?
  end

  def finished_turn?
    %w[stood busted blackjack].include?(status)
  end

  # For dealer: get the visible (up) card
  def up_card
    return nil unless is_dealer? && hand.cards.any?
    hand.cards.first
  end

  # For dealer: get the hidden (hole) card
  def hole_card
    return nil unless is_dealer? && hand.cards.size >= 2
    hand.cards.second
  end

  def human?
    !is_computer? && !is_dealer?
  end

  def computer?
    is_computer? && !is_dealer?
  end
end
