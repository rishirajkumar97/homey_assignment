class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :password_digest
      t.string :role
      t.string :full_name
      t.string :email

      t.timestamps
    end
    add_index :users, :user_name, unique: true
    add_index :users, :email, unique: true
  end
end
