# frozen_string_literal: true

# Service for providing basic strategy advice
class BasicStrategyService
  attr_reader :hand, :dealer_up_card

  ACTIONS = {
    hit: "Hit",
    stand: "Stand",
    double: "Double Down",
    split: "Split"
  }.freeze

  def initialize(hand, dealer_up_card)
    @hand = hand.is_a?(Hand) ? hand : Hand.from_a(hand)
    @dealer_up_card = dealer_up_card.is_a?(Card) ? dealer_up_card : Card.from_h(dealer_up_card)
  end

  # Get the recommended action
  def recommended_action
    return :stand if hand.blackjack?
    return :stand if hand.busted?

    if hand.soft?
      soft_hand_action
    else
      hard_hand_action
    end
  end

  # Get a human-readable recommendation
  def advice
    action = recommended_action
    {
      action: ACTIONS[action],
      reason: action_reason(action),
      player_total: hand.best_value,
      dealer_shows: dealer_up_card.to_s,
      is_soft: hand.soft?
    }
  end

  private

  def dealer_value
    @dealer_value ||= dealer_up_card.ace? ? 11 : dealer_up_card.value
  end

  def hard_hand_action
    value = hand.best_value

    case value
    when 17..21
      :stand
    when 13..16
      dealer_value >= 7 ? :hit : :stand
    when 12
      (dealer_value >= 4 && dealer_value <= 6) ? :stand : :hit
    when 11
      :double # Always double on 11
    when 10
      dealer_value <= 9 ? :double : :hit
    when 9
      (dealer_value >= 3 && dealer_value <= 6) ? :double : :hit
    else
      :hit
    end
  end

  def soft_hand_action
    value = hand.best_value

    case value
    when 20..21
      :stand
    when 19
      :stand
    when 18
      if dealer_value >= 9
        :hit
      elsif dealer_value >= 3 && dealer_value <= 6
        :double
      else
        :stand
      end
    when 17
      (dealer_value >= 3 && dealer_value <= 6) ? :double : :hit
    when 15..16
      (dealer_value >= 4 && dealer_value <= 6) ? :double : :hit
    when 13..14
      (dealer_value >= 5 && dealer_value <= 6) ? :double : :hit
    else
      :hit
    end
  end

  def action_reason(action)
    case action
    when :stand
      stand_reason
    when :hit
      hit_reason
    when :double
      double_reason
    else
      "Follow basic strategy"
    end
  end

  def stand_reason
    value = hand.best_value

    if value >= 17
      "Stand on #{value} - strong hand, risk of busting is too high."
    elsif dealer_value <= 6
      "Stand and let the dealer bust. Dealer showing #{dealer_up_card} is weak."
    else
      "Stand with #{value} against dealer's #{dealer_up_card}."
    end
  end

  def hit_reason
    value = hand.best_value

    if value <= 11
      "Hit - you cannot bust with #{value}."
    elsif dealer_value >= 7
      "Hit against dealer's strong #{dealer_up_card}. Need to improve your #{value}."
    else
      "Hit to improve your hand."
    end
  end

  def double_reason
    value = hand.best_value

    if value == 11
      "Double on 11 - best opportunity to get 21."
    elsif value == 10
      "Double on 10 against dealer's weak #{dealer_up_card}."
    else
      "Double - favorable situation against dealer's #{dealer_up_card}."
    end
  end
end
