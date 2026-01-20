class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name, null: false
      t.boolean :is_computer, default: false, null: false
      t.boolean :is_dealer, default: false, null: false
      t.integer :skill_level
      t.json :hand_cards, default: []
      t.string :status, default: "waiting"
      t.integer :position, null: false
      t.string :result

      t.timestamps
    end

    add_index :players, [:game_id, :position], unique: true
  end
end
