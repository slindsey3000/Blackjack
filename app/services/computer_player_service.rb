# frozen_string_literal: true

# Service for handling computer player decisions
class ComputerPlayerService
  attr_reader :player, :dealer_up_card

  def initialize(player, dealer_up_card)
    @player = player
    @dealer_up_card = dealer_up_card
  end

  # Should the computer player hit?
  def should_hit?
    return false if player.busted? || player.blackjack?

    case player.skill_level
    when "low"
      low_skill_decision
    when "medium"
      medium_skill_decision
    when "high"
      high_skill_decision
    else
      low_skill_decision
    end
  end

  private

  # Low skill: Simple strategy, hits until 15+
  # Makes occasional random mistakes
  def low_skill_decision
    value = player.hand_value

    # Random chance to make a mistake (20%)
    if rand < 0.2
      return rand < 0.5 # Random hit or stand
    end

    # Simple rule: hit until 15
    value < 15
  end

  # Medium skill: Follows basic strategy about 70% of the time
  def medium_skill_decision
    # 30% chance to deviate from optimal
    if rand < 0.3
      # Fall back to simple strategy
      return player.hand_value < 16
    end

    # Otherwise use basic strategy
    basic_strategy_decision
  end

  # High skill: Follows basic strategy nearly perfectly (95%)
  def high_skill_decision
    # 5% chance of minor error
    if rand < 0.05
      return player.hand_value < 17
    end

    basic_strategy_decision
  end

  # Basic strategy decision based on player hand and dealer up card
  def basic_strategy_decision
    value = player.hand_value
    soft = player.soft_hand?
    dealer_value = dealer_up_card_value

    if soft
      soft_hand_strategy(value, dealer_value)
    else
      hard_hand_strategy(value, dealer_value)
    end
  end

  def dealer_up_card_value
    return 10 if dealer_up_card.nil?
    dealer_up_card.value
  end

  # Basic strategy for hard hands
  def hard_hand_strategy(value, dealer_value)
    case value
    when 17..21
      false # Always stand on 17+
    when 13..16
      # Stand against dealer 2-6, hit against 7+
      dealer_value >= 7
    when 12
      # Stand against 4-6, hit otherwise
      dealer_value < 4 || dealer_value > 6
    when 9..11
      # Always hit (simplified - would double in real basic strategy)
      true
    else
      # Always hit on 8 or less
      true
    end
  end

  # Basic strategy for soft hands
  def soft_hand_strategy(value, dealer_value)
    case value
    when 19..21
      false # Stand on soft 19+
    when 18
      # Stand against 2-8, hit against 9-A
      dealer_value >= 9
    else
      # Hit on soft 17 or less
      true
    end
  end
end
