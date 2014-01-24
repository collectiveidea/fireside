class AddRoomIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :room_id, :integer
    add_index :messages, :room_id
  end
end
