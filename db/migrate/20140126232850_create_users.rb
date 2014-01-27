class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :api_auth_token, limit: 40
      t.boolean :admin, default: false, null: false
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :api_auth_token, unique: true
    add_index :users, :created_at
  end
end
