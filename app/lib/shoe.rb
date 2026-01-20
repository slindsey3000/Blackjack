# frozen_string_literal: true

# Represents a multi-deck shoe for dealing cards
class Shoe
  DEFAULT_DECK_COUNT = 6
  RESHUFFLE_THRESHOLD = 0.25 # Reshuffle when 25% of cards remain

  attr_reader :deck_count, :cards

  def initialize(deck_count: DEFAULT_DECK_COUNT, cards: nil)
    @deck_count = deck_count
    @cards = cards || build_and_shuffle
  end

  # Deal a single card from the shoe
  def deal
    reshuffle! if needs_reshuffle?
    @cards.pop
  end

  # Deal multiple cards
  def deal_cards(count)
    count.times.map { deal }
  end

  def remaining_cards
    @cards.size
  end

  def total_cards
    deck_count * 52
  end

  def decks_remaining
    remaining_cards.to_f / 52
  end

  def needs_reshuffle?
    remaining_cards < (total_cards * RESHUFFLE_THRESHOLD)
  end

  def reshuffle!
    @cards = build_and_shuffle
  end

  def to_a
    @cards.map(&:to_h)
  end

  def self.from_a(array, deck_count: DEFAULT_DECK_COUNT)
    cards = (array || []).map { |h| Card.from_h(h) }
    new(deck_count: deck_count, cards: cards)
  end

  private

  def build_and_shuffle
    cards = []
    deck_count.times do
      Card::SUITS.each do |suit|
        Card::RANKS.each do |rank|
          cards << Card.new(rank, suit)
        end
      end
    end
    cards.shuffle
  end
end
