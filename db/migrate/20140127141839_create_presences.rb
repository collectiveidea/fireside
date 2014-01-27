class CreatePresences < ActiveRecord::Migration
  def change
    create_table :presences do |t|
      t.integer :user_id
      t.integer :room_id
      t.timestamps
    end

    add_index :presences, [:user_id, :room_id], unique: true
    add_index :presences, [:room_id, :user_id], unique: true
  end
end
