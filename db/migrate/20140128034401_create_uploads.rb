class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.integer :user_id
      t.integer :room_id
      t.timestamps
    end

    add_index :uploads, :user_id
    add_index :uploads, :room_id
    add_index :uploads, :created_at
  end
end
