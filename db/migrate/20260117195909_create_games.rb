class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :status, default: "waiting", null: false
      t.json :shoe_cards, default: []
      t.json :revealed_cards, default: []
      t.integer :current_player_position, default: 0

      t.timestamps
    end
  end
end
