# This migration comes from nabu_engine (originally 20170606081923)
class CreateNabuComments < ActiveRecord::Migration[5.0]
  def up
    create_table :comments, force: true do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.string :title
      t.text :body
      t.string :subject
      t.integer :commentator_id, null: false
      t.integer :parent_id

      t.timestamps
    end


    create_table :comment_hierarchies, id: false do |t|
      t.integer  :ancestor_id, null: false   # ID of the parent/grandparent/great-grandparent/... comments
      t.integer  :descendant_id, null: false # ID of the target comment
      t.integer  :generations, null: false   # Number of generations between the ancestor and the descendant. Parent/child = 1, for example.
    end

    # For "all progeny of…" and leaf selects:
    add_index :comment_hierarchies, [:ancestor_id, :descendant_id, :generations],
              unique: true, name: "comment_anc_desc_udx"

    # For "all ancestors of…" selects,
    add_index :comment_hierarchies, [:descendant_id],
              name: "comment_desc_idx"

    add_index :comments, :commentator_id
    add_index :comments, [:commentable_id, :commentable_type]
  end

  def down
    remove_index :comment_hierarchies, name: 'comment_anc_desc_udx'
    remove_index :comment_hierarchies, name: 'comment_desc_idx'
    drop_table :comment_hierarchies

    remove_index :comments, :commentator_id
    remove_index :comments, [:commentable_id, :commentable_type]
    drop_table :comments
  end
  
end
