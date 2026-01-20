Rails.application.routes.draw do
  # Root path - start a new game
  root "games#new"

  # Game resources
  resources :games, only: [:index, :new, :create, :show] do
    member do
      post :deal
      post :hit
      post :stand
      post :add_player
      post :remove_player
      post :new_round
    end
  end

  # Card counting dashboard
  get "dashboard/:game_id", to: "dashboard#show", as: :dashboard

  # Health check for load balancers
  get "up" => "rails/health#show", as: :rails_health_check
end
