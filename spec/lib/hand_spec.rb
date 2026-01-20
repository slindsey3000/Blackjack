# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hand do
  describe "#best_value" do
    it "calculates simple hand value" do
      hand = Hand.new([
        Card.new("7", "hearts"),
        Card.new("9", "clubs")
      ])
      expect(hand.best_value).to eq(16)
    end

    it "handles Ace as 11 when beneficial" do
      hand = Hand.new([
        Card.new("A", "hearts"),
        Card.new("7", "clubs")
      ])
      expect(hand.best_value).to eq(18) # A=11, 7=7
    end

    it "handles Ace as 1 to avoid bust" do
      hand = Hand.new([
        Card.new("A", "hearts"),
        Card.new("7", "clubs"),
        Card.new("8", "diamonds")
      ])
      expect(hand.best_value).to eq(16) # A=1, 7=7, 8=8
    end

    it "handles multiple Aces" do
      hand = Hand.new([
        Card.new("A", "hearts"),
        Card.new("A", "clubs"),
        Card.new("9", "diamonds")
      ])
      expect(hand.best_value).to eq(21) # A=11, A=1, 9=9
    end

    it "calculates blackjack correctly" do
      hand = Hand.new([
        Card.new("A", "hearts"),
        Card.new("K", "clubs")
      ])
      expect(hand.best_value).to eq(21)
    end
  end

  describe "#blackjack?" do
    it "returns true for Ace + ten-card" do
      hand = Hand.new([
        Card.new("A", "hearts"),
        Card.new("K", "clubs")
      ])
      expect(hand.blackjack?).to be true
    end

    it "returns false for 21 with more than 2 cards" do
      hand = Hand.new([
        Card.new("7", "hearts"),
        Card.new("7", "clubs"),
        Card.new("7", "diamonds")
      ])
      expect(hand.best_value).to eq(21)
      expect(hand.blackjack?).to be false
    end

    it "returns false for non-21 two card hand" do
      hand = Hand.new([
        Card.new("K", "hearts"),
        Card.new("9", "clubs")
      ])
      expect(hand.blackjack?).to be false
    end
  end

  describe "#busted?" do
    it "returns true when hand exceeds 21" do
      hand = Hand.new([
        Card.new("K", "hearts"),
        Card.new("Q", "clubs"),
        Card.new("5", "diamonds")
      ])
      expect(hand.busted?).to be true
    end

    it "returns false when hand is 21 or under" do
      hand = Hand.new([
        Card.new("K", "hearts"),
        Card.new("Q", "clubs")
      ])
      expect(hand.busted?).to be false
    end
  end

  describe "#soft?" do
    it "returns true for soft hand" do
      hand = Hand.new([
        Card.new("A", "hearts"),
        Card.new("6", "clubs")
      ])
      expect(hand.soft?).to be true
    end

    it "returns false for hard hand with Ace counted as 1" do
      hand = Hand.new([
        Card.new("A", "hearts"),
        Card.new("6", "clubs"),
        Card.new("K", "diamonds")
      ])
      expect(hand.best_value).to eq(17)
      expect(hand.soft?).to be false
    end

    it "returns false for hand without Ace" do
      hand = Hand.new([
        Card.new("K", "hearts"),
        Card.new("7", "clubs")
      ])
      expect(hand.soft?).to be false
    end
  end

  describe "#add_card" do
    it "adds a card to the hand" do
      hand = Hand.new
      hand.add_card(Card.new("A", "hearts"))

      expect(hand.cards.size).to eq(1)
      expect(hand.best_value).to eq(11)
    end
  end
end
