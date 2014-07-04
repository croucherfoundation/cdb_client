class Taggings < ActiveRecord::Migration
  def change
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
