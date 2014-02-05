class AddMetadataToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :metadata, :text
  end
end
