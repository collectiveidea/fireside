class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :topic
      t.boolean :open_to_guests, default: false, null: false
      t.string :active_token_value, limit: 5
      t.boolean :locked, default: false, null: false
      t.timestamps
    end

    add_index :rooms, :name, unique: true
    add_index :rooms, :active_token_value, unique: true
    add_index :rooms, :created_at
  end
end
