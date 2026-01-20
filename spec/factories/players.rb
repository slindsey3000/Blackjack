FactoryBot.define do
  factory :player do
    association :game
    name { "Player" }
    is_computer { false }
    is_dealer { false }
    skill_level { nil }
    hand_cards { [] }
    status { "waiting" }
    sequence(:position) { |n| n }
    result { nil }

    trait :dealer do
      name { "Dealer" }
      is_dealer { true }
      is_computer { true }
      position { -1 }
    end

    trait :computer do
      is_computer { true }
      skill_level { :medium }
      sequence(:name) { |n| "CPU #{n}" }
    end

    trait :low_skill do
      computer
      skill_level { :low }
    end

    trait :medium_skill do
      computer
      skill_level { :medium }
    end

    trait :high_skill do
      computer
      skill_level { :high }
    end

    trait :with_blackjack do
      hand_cards { [{ rank: "A", suit: "spades" }, { rank: "K", suit: "hearts" }] }
      status { "blackjack" }
    end

    trait :busted do
      hand_cards { [{ rank: "K", suit: "spades" }, { rank: "Q", suit: "hearts" }, { rank: "5", suit: "clubs" }] }
      status { "busted" }
    end
  end
end
