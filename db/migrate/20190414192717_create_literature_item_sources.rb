class CreateLiteratureItemSources < ActiveRecord::Migration[5.2]
  def change
    create_table :literature_item_sources do |t|
      t.references :literature_item, foreign_key: true
      t.references :source, foreign_key: true
      t.string :locator

      t.timestamps
    end
    add_index :literature_item_sources, [:literature_item_id, :source_id], name: 'index_lit_source_on_item_and_source', unique: true
  end
end
