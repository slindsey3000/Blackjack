# frozen_string_literal: true

# Represents a blackjack hand with value calculation
class Hand
  attr_reader :cards

  def initialize(cards = [])
    @cards = cards.map do |card|
      card.is_a?(Card) ? card : Card.from_h(card)
    end
  end

  def add_card(card)
    card = card.is_a?(Card) ? card : Card.from_h(card)
    @cards << card
    card
  end

  # Calculate all possible hand values (accounting for Aces as 1 or 11)
  def possible_values
    values = [0]

    cards.each do |card|
      if card.ace?
        # For each Ace, branch into two possibilities: 1 or 11
        values = values.flat_map { |v| [v + 1, v + 11] }
      else
        values = values.map { |v| v + card.value }
      end
    end

    values.uniq.sort
  end

  # The best value: highest that doesn't bust, or lowest if all bust
  def best_value
    valid = possible_values.select { |v| v <= 21 }
    valid.empty? ? possible_values.min : valid.max
  end

  # Is this a soft hand? (contains an Ace counted as 11)
  def soft?
    return false unless cards.any?(&:ace?)

    # It's soft if we can count an Ace as 11 without busting
    hard_total = cards.sum { |c| c.ace? ? 1 : c.value }
    soft_total = hard_total + 10 # Count one Ace as 11 instead of 1

    soft_total <= 21 && soft_total == best_value
  end

  # Has the hand busted?
  def busted?
    best_value > 21
  end

  # Is this a natural blackjack? (exactly 2 cards totaling 21)
  def blackjack?
    cards.size == 2 && best_value == 21
  end

  def size
    cards.size
  end

  def empty?
    cards.empty?
  end

  def clear
    @cards = []
  end

  def to_a
    cards.map(&:to_h)
  end

  def self.from_a(array)
    new(array || [])
  end

  def to_s
    cards.map(&:to_s).join(" ")
  end
end
