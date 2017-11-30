class CreateSourceHierarchies < ActiveRecord::Migration[5.0]
  def change
    create_table :source_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :source_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "source_anc_desc_idx"

    add_index :source_hierarchies, [:descendant_id],
      name: "source_desc_idx"
  end
end
