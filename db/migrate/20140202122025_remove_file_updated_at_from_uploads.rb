class RemoveFileUpdatedAtFromUploads < ActiveRecord::Migration
  def up
    remove_column :uploads, :file_updated_at
  end

  def down
    add_column :uploads, :file_updated_at, :datetime
  end
end
