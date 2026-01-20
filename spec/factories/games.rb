FactoryBot.define do
  factory :game do
    status { "waiting" }
    # Let the model initialize the shoe via after_initialize callback
    revealed_cards { [] }
    current_player_position { 0 }

    trait :with_dealer do
      after(:create) do |game|
        create(:player, :dealer, game: game)
      end
    end

    trait :with_player do
      after(:create) do |game|
        create(:player, :dealer, game: game)
        create(:player, game: game, position: 0)
      end
    end

    trait :in_progress do
      status { "playing" }
    end

    trait :finished do
      status { "finished" }
    end
  end
end
