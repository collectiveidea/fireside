class AddStarredToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :starred, :boolean, default: false, null: false
    add_index :messages, :starred
  end
end
