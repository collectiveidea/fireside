class AddPrivateToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :private, :boolean, default: false, null: false
    add_index :messages, :private
  end
end
