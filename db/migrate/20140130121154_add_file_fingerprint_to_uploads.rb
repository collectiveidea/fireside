class AddFileFingerprintToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :file_fingerprint, :string
    add_index :uploads, :file_fingerprint
  end
end
