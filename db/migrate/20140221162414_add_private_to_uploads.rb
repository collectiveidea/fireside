class AddPrivateToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :private, :boolean, default: false, null: false
    add_index :uploads, :private
  end
end
