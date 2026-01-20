# frozen_string_literal: true

require "rails_helper"

RSpec.describe Player, type: :model do
  describe "associations" do
    it "belongs to a game" do
      player = create(:player)
      expect(player.game).to be_present
    end
  end

  describe "validations" do
    it "requires a name" do
      player = build(:player, name: nil)
      expect(player).not_to be_valid
    end

    it "requires a position" do
      player = build(:player, position: nil)
      expect(player).not_to be_valid
    end

    it "requires skill_level for computer players" do
      player = build(:player, is_computer: true, skill_level: nil)
      expect(player).not_to be_valid
    end
  end

  describe "#hand" do
    let(:player) { create(:player) }

    it "returns a Hand object" do
      expect(player.hand).to be_a(Hand)
    end

    it "deserializes stored cards" do
      player.hand_cards = [{ rank: "A", suit: "spades" }, { rank: "K", suit: "hearts" }]
      player.save!
      player.reload

      expect(player.hand.cards.size).to eq(2)
      expect(player.hand.best_value).to eq(21)
    end
  end

  describe "#add_card" do
    let(:player) { create(:player) }

    it "adds card to hand and persists" do
      card = Card.new("A", "spades")
      player.add_card(card)

      expect(player.hand.cards.size).to eq(1)
      expect(player.hand_cards.size).to eq(1)
    end
  end

  describe "#hand_value" do
    let(:player) { create(:player) }

    it "delegates to hand" do
      player.hand_cards = [{ rank: "K", suit: "spades" }, { rank: "7", suit: "hearts" }]
      expect(player.hand_value).to eq(17)
    end
  end

  describe "#blackjack?" do
    let(:player) { create(:player) }

    it "returns true for blackjack hand" do
      player.hand_cards = [{ rank: "A", suit: "spades" }, { rank: "K", suit: "hearts" }]
      expect(player.blackjack?).to be true
    end

    it "returns false for non-blackjack 21" do
      player.hand_cards = [
        { rank: "7", suit: "spades" },
        { rank: "7", suit: "hearts" },
        { rank: "7", suit: "clubs" }
      ]
      expect(player.blackjack?).to be false
    end
  end

  describe "#busted?" do
    let(:player) { create(:player) }

    it "returns true when hand exceeds 21" do
      player.hand_cards = [
        { rank: "K", suit: "spades" },
        { rank: "Q", suit: "hearts" },
        { rank: "5", suit: "clubs" }
      ]
      expect(player.busted?).to be true
    end
  end

  describe "#up_card" do
    let(:player) { create(:player, :dealer) }

    it "returns first card for dealer" do
      player.hand_cards = [
        { rank: "K", suit: "spades" },
        { rank: "7", suit: "hearts" }
      ]
      expect(player.up_card.rank).to eq("K")
    end

    it "returns nil for non-dealer" do
      non_dealer = create(:player)
      expect(non_dealer.up_card).to be_nil
    end
  end

  describe "#human? and #computer?" do
    it "identifies human players" do
      human = create(:player, is_computer: false, is_dealer: false)
      expect(human.human?).to be true
      expect(human.computer?).to be false
    end

    it "identifies computer players" do
      cpu = create(:player, :computer)
      expect(cpu.human?).to be false
      expect(cpu.computer?).to be true
    end
  end
end
