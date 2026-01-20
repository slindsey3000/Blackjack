# frozen_string_literal: true

# Service for Hi-Lo card counting calculations
class CardCountingService
  attr_reader :game

  # Hi-Lo counting values
  # 2-6: +1 (low cards, good for player when removed)
  # 7-9: 0 (neutral)
  # 10-A: -1 (high cards, bad for player when removed)

  def initialize(game)
    @game = game
  end

  # Calculate the running count from all revealed cards
  def running_count
    revealed_cards.sum { |card| counting_value(card) }
  end

  # Calculate the true count (running count / decks remaining)
  def true_count
    decks = decks_remaining
    return 0 if decks <= 0

    (running_count.to_f / decks).round(1)
  end

  # Get the number of decks remaining in the shoe
  def decks_remaining
    remaining = game.shoe_cards&.size || 0
    (remaining.to_f / 52).round(1)
  end

  # Get the total cards remaining
  def cards_remaining
    game.shoe_cards&.size || 0
  end

  # Get all revealed cards as Card objects
  def revealed_cards
    (game.revealed_cards || []).map { |h| Card.from_h(h) }
  end

  # Get a count of each card type revealed
  def cards_seen_breakdown
    breakdown = Hash.new(0)
    revealed_cards.each do |card|
      breakdown[card.rank] += 1
    end
    breakdown
  end

  # Get recent cards (last N revealed)
  def recent_cards(limit = 10)
    revealed_cards.last(limit)
  end

  # Provide advice based on true count
  def count_advice
    tc = true_count

    if tc >= 2
      {
        advantage: :player,
        message: "Favorable count (+#{tc}). The deck is rich in high cards.",
        bet_advice: "Consider increasing bets when allowed."
      }
    elsif tc <= -2
      {
        advantage: :house,
        message: "Unfavorable count (#{tc}). The deck is depleted of high cards.",
        bet_advice: "Consider minimum bets when betting is implemented."
      }
    else
      {
        advantage: :neutral,
        message: "Neutral count (#{tc}). Standard play recommended.",
        bet_advice: "Maintain normal betting patterns."
      }
    end
  end

  private

  def counting_value(card)
    card = Card.from_h(card) unless card.is_a?(Card)
    card.counting_value
  end
end
