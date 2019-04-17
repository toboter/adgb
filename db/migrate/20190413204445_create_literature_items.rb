class CreateLiteratureItems < ActiveRecord::Migration[5.2]
  def change
    create_table :literature_items do |t|
      t.jsonb   :biblio_data, null: false, default: {}
      t.string  :ver
      t.string  :publ
      t.string  :jahr
  
      t.timestamps
    end
    add_index   :literature_items, [:ver, :publ, :jahr], unique: true
    add_index   :literature_items, :biblio_data, using: :gin
    add_column  :artefact_references, :literature_item_id, :integer, index: true
  end
end
