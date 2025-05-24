class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.text :content
      t.integer :status
      t.integer :creator_id
      t.string :creator_type

      t.timestamps
    end
  end
end
