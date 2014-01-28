class AddAttachmentFileToUploads < ActiveRecord::Migration
  def self.up
    change_table :uploads do |t|
      t.attachment :file
    end
  end

  def self.down
    drop_attached_file :uploads, :file
  end
end
