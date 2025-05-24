class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities do |t|
      t.string :type
      t.text :content
      t.references :project, null: false, foreign_key: true
      t.integer :creator_id, null: false
      t.string :creator_type, null: false

      t.timestamps
    end
  end
end
