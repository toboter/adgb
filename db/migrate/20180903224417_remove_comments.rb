class RemoveComments < ActiveRecord::Migration[5.1]
  def change
    remove_index :comment_hierarchies, name: 'comment_anc_desc_udx'
    remove_index :comment_hierarchies, name: 'comment_desc_idx'
    drop_table :comment_hierarchies

    remove_index :comments, :commentator_id
    remove_index :comments, [:commentable_id, :commentable_type]
    drop_table :comments
  end
end
