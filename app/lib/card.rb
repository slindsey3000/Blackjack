# frozen_string_literal: true

# Represents a playing card with rank and suit
class Card
  SUITS = %w[hearts diamonds clubs spades].freeze
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze

  SUIT_SYMBOLS = {
    "hearts" => "♥",
    "diamonds" => "♦",
    "clubs" => "♣",
    "spades" => "♠"
  }.freeze

  SUIT_COLORS = {
    "hearts" => "red",
    "diamonds" => "red",
    "clubs" => "black",
    "spades" => "black"
  }.freeze

  attr_reader :rank, :suit

  def initialize(rank, suit)
    raise ArgumentError, "Invalid rank: #{rank}" unless RANKS.include?(rank)
    raise ArgumentError, "Invalid suit: #{suit}" unless SUITS.include?(suit)

    @rank = rank
    @suit = suit
  end

  # Base value of the card (Ace counts as 11 by default)
  def value
    case rank
    when "A" then 11
    when "K", "Q", "J" then 10
    else rank.to_i
    end
  end

  # Is this a ten-value card?
  def ten_card?
    %w[10 J Q K].include?(rank)
  end

  # Is this an Ace?
  def ace?
    rank == "A"
  end

  # Hi-Lo card counting value: 2-6 = +1, 7-9 = 0, 10-A = -1
  def counting_value
    case rank
    when "2", "3", "4", "5", "6" then 1
    when "7", "8", "9" then 0
    else -1
    end
  end

  def suit_symbol
    SUIT_SYMBOLS[suit]
  end

  def color
    SUIT_COLORS[suit]
  end

  def to_s
    "#{rank}#{suit_symbol}"
  end

  def to_h
    { rank: rank, suit: suit }
  end

  def self.from_h(hash)
    new(hash[:rank] || hash["rank"], hash[:suit] || hash["suit"])
  end

  def ==(other)
    return false unless other.is_a?(Card)
    rank == other.rank && suit == other.suit
  end

  alias eql? ==

  def hash
    [rank, suit].hash
  end
end
