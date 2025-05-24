class CreateActivityReferences < ActiveRecord::Migration[7.2]
  def change
    create_table :activity_references do |t|
      t.references :activity, null: false, foreign_key: true
      t.integer :reference_id, null: false
      t.string :reference_klass, null: false

      t.timestamps
    end
  end
end
