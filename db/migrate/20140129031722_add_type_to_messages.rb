class AddTypeToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :type, :string
    add_index :messages, :type
  end
end
