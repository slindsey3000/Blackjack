# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardCountingService do
  let(:game) { create(:game) }
  let(:service) { described_class.new(game) }

  describe "#running_count" do
    it "returns 0 with no revealed cards" do
      expect(service.running_count).to eq(0)
    end

    it "increments for low cards (2-6)" do
      game.revealed_cards = [
        { rank: "2", suit: "hearts" },
        { rank: "3", suit: "clubs" },
        { rank: "4", suit: "diamonds" },
        { rank: "5", suit: "spades" },
        { rank: "6", suit: "hearts" }
      ]

      expect(service.running_count).to eq(5)
    end

    it "decrements for high cards (10-A)" do
      game.revealed_cards = [
        { rank: "10", suit: "hearts" },
        { rank: "J", suit: "clubs" },
        { rank: "Q", suit: "diamonds" },
        { rank: "K", suit: "spades" },
        { rank: "A", suit: "hearts" }
      ]

      expect(service.running_count).to eq(-5)
    end

    it "ignores neutral cards (7-9)" do
      game.revealed_cards = [
        { rank: "7", suit: "hearts" },
        { rank: "8", suit: "clubs" },
        { rank: "9", suit: "diamonds" }
      ]

      expect(service.running_count).to eq(0)
    end

    it "calculates correctly with mixed cards" do
      game.revealed_cards = [
        { rank: "2", suit: "hearts" },  # +1
        { rank: "K", suit: "clubs" },   # -1
        { rank: "5", suit: "diamonds" }, # +1
        { rank: "8", suit: "spades" },  # 0
        { rank: "A", suit: "hearts" }   # -1
      ]

      expect(service.running_count).to eq(0)
    end
  end

  describe "#true_count" do
    it "divides running count by decks remaining" do
      # 6 decks = 312 cards
      # If 52 cards played (1 deck), 5 decks remain
      game.shoe_cards = Array.new(260) { { rank: "2", suit: "hearts" } } # ~5 decks
      game.revealed_cards = Array.new(10) { { rank: "2", suit: "hearts" } } # +10 count

      # True count = 10 / 5 = 2
      expect(service.true_count).to eq(2.0)
    end
  end

  describe "#decks_remaining" do
    it "calculates decks from remaining cards" do
      game.shoe_cards = Array.new(156) { { rank: "2", suit: "hearts" } } # 3 decks

      expect(service.decks_remaining).to eq(3.0)
    end
  end

  describe "#count_advice" do
    it "indicates player advantage for high positive count" do
      # Reduce shoe to about 2 decks remaining so true count is significant
      game.shoe_cards = Array.new(104) { { rank: "7", suit: "hearts" } }
      # Running count of +10 / 2 decks = true count of +5
      game.revealed_cards = Array.new(10) { { rank: "5", suit: "hearts" } }

      advice = service.count_advice
      expect(advice[:advantage]).to eq(:player)
    end

    it "indicates house advantage for high negative count" do
      # Reduce shoe to about 2 decks remaining
      game.shoe_cards = Array.new(104) { { rank: "7", suit: "hearts" } }
      # Running count of -10 / 2 decks = true count of -5
      game.revealed_cards = Array.new(10) { { rank: "K", suit: "hearts" } }

      advice = service.count_advice
      expect(advice[:advantage]).to eq(:house)
    end

    it "indicates neutral for near-zero count" do
      game.revealed_cards = []

      advice = service.count_advice
      expect(advice[:advantage]).to eq(:neutral)
    end
  end

  describe "#recent_cards" do
    it "returns last N revealed cards" do
      game.revealed_cards = (1..20).map { |i| { rank: "#{(i % 9) + 2}", suit: "hearts" } }

      recent = service.recent_cards(5)
      expect(recent.size).to eq(5)
    end
  end
end
