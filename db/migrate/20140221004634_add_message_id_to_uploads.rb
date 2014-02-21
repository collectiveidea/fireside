class AddMessageIdToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :message_id, :integer
    add_index :uploads, :message_id
  end
end
