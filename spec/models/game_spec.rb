# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game, type: :model do
  describe "associations" do
    it "has many players" do
      game = create(:game)
      create(:player, game: game, position: 0)
      create(:player, game: game, position: 1)

      expect(game.players.count).to eq(2)
    end
  end

  describe "validations" do
    it "validates status inclusion" do
      game = build(:game, status: "invalid")
      expect(game).not_to be_valid
    end

    it "accepts valid statuses" do
      Game::STATUSES.each do |status|
        game = build(:game, status: status)
        expect(game).to be_valid
      end
    end
  end

  describe "#initialize_shoe" do
    it "creates a 6-deck shoe on new game" do
      # Use Game.new directly, not factory, to test the callback
      game = Game.new(status: "waiting")
      expect(game.shoe_cards.size).to eq(6 * 52)
    end
  end

  describe "#can_add_player?" do
    let(:game) { create(:game, :with_dealer) }

    it "returns true when waiting and under max players" do
      create(:player, game: game, position: 0)
      expect(game.can_add_player?).to be true
    end

    it "returns false when not waiting" do
      game.update!(status: "playing")
      expect(game.can_add_player?).to be false
    end

    it "returns false when table is full" do
      6.times { |i| create(:player, game: game, position: i) }
      expect(game.can_add_player?).to be false
    end
  end

  describe "#dealer" do
    let(:game) { create(:game) }

    it "returns the dealer player" do
      dealer = create(:player, :dealer, game: game)
      create(:player, game: game, position: 0)

      expect(game.dealer).to eq(dealer)
    end
  end

  describe "#active_players" do
    let(:game) { create(:game) }

    it "returns non-dealer players in position order" do
      create(:player, :dealer, game: game)
      player2 = create(:player, game: game, position: 1, name: "Second")
      player1 = create(:player, game: game, position: 0, name: "First")

      expect(game.active_players.map(&:name)).to eq(%w[First Second])
    end
  end

  describe "#reveal_card" do
    let(:game) { create(:game) }

    it "adds card to revealed cards" do
      card = Card.new("A", "spades")
      game.reveal_card(card)

      expect(game.revealed_cards.size).to eq(1)
      expect(game.revealed_cards.first["rank"]).to eq("A")
    end
  end
end
