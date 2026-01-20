# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :set_game

  def show
    @counting_service = CardCountingService.new(@game)
    @running_count = @counting_service.running_count
    @true_count = @counting_service.true_count
    @cards_remaining = @counting_service.cards_remaining
    @decks_remaining = @counting_service.decks_remaining
    @recent_cards = @counting_service.recent_cards(12)
    @count_advice = @counting_service.count_advice
    @cards_breakdown = @counting_service.cards_seen_breakdown

    # If player has cards and dealer has up card, provide strategy advice
    @strategy_advice = nil
    human_player = @game.active_players.find(&:human?)
    dealer = @game.dealer

    if human_player && human_player.hand.cards.any? && dealer&.up_card
      strategy_service = BasicStrategyService.new(human_player.hand, dealer.up_card)
      @strategy_advice = strategy_service.advice
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end
end
