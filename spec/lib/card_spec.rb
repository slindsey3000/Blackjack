# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card do
  describe "#initialize" do
    it "creates a valid card" do
      card = Card.new("A", "spades")
      expect(card.rank).to eq("A")
      expect(card.suit).to eq("spades")
    end

    it "raises error for invalid rank" do
      expect { Card.new("X", "spades") }.to raise_error(ArgumentError)
    end

    it "raises error for invalid suit" do
      expect { Card.new("A", "invalid") }.to raise_error(ArgumentError)
    end
  end

  describe "#value" do
    it "returns 11 for Ace" do
      expect(Card.new("A", "hearts").value).to eq(11)
    end

    it "returns 10 for face cards" do
      expect(Card.new("K", "hearts").value).to eq(10)
      expect(Card.new("Q", "hearts").value).to eq(10)
      expect(Card.new("J", "hearts").value).to eq(10)
    end

    it "returns pip value for number cards" do
      expect(Card.new("7", "hearts").value).to eq(7)
      expect(Card.new("2", "hearts").value).to eq(2)
      expect(Card.new("10", "hearts").value).to eq(10)
    end
  end

  describe "#ten_card?" do
    it "returns true for 10, J, Q, K" do
      expect(Card.new("10", "hearts").ten_card?).to be true
      expect(Card.new("J", "hearts").ten_card?).to be true
      expect(Card.new("Q", "hearts").ten_card?).to be true
      expect(Card.new("K", "hearts").ten_card?).to be true
    end

    it "returns false for non-ten cards" do
      expect(Card.new("A", "hearts").ten_card?).to be false
      expect(Card.new("9", "hearts").ten_card?).to be false
    end
  end

  describe "#counting_value" do
    it "returns +1 for low cards (2-6)" do
      %w[2 3 4 5 6].each do |rank|
        expect(Card.new(rank, "hearts").counting_value).to eq(1)
      end
    end

    it "returns 0 for neutral cards (7-9)" do
      %w[7 8 9].each do |rank|
        expect(Card.new(rank, "hearts").counting_value).to eq(0)
      end
    end

    it "returns -1 for high cards (10-A)" do
      %w[10 J Q K A].each do |rank|
        expect(Card.new(rank, "hearts").counting_value).to eq(-1)
      end
    end
  end

  describe "#to_s" do
    it "returns a human-readable string" do
      expect(Card.new("A", "spades").to_s).to eq("A♠")
      expect(Card.new("K", "hearts").to_s).to eq("K♥")
    end
  end

  describe "#to_h and .from_h" do
    it "serializes and deserializes correctly" do
      card = Card.new("Q", "diamonds")
      hash = card.to_h
      restored = Card.from_h(hash)

      expect(restored.rank).to eq(card.rank)
      expect(restored.suit).to eq(card.suit)
    end
  end
end
