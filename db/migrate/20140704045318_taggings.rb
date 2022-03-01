class Taggings < ActiveRecord::Migration[4.2]
  def change
    unless ActiveRecord::Base.connection.table_exists? 'taggings'
      create_table :taggings do |t|
        t.integer :tag_id
        t.integer :taggee_id
        t.string :taggee_type
        t.timestamps
      end
      add_index :taggings, :tag_id
      add_index :taggings, [:taggee_type, :taggee_id], name: "taggee"
    end
  end
end
