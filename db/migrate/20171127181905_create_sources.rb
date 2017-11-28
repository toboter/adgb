class CreateSources < ActiveRecord::Migration[5.0]
  def change
    create_table :sources do |t|
      t.string :slug
      t.string :identifier_stable
      t.string :identifier_temp
      t.string :type
      t.jsonb :type_data
      t.integer :parent_id
      t.text :remarks

      t.timestamps
    end
    add_index :sources, :slug
    add_index :sources, :identifier_stable
    add_index :sources, :parent_id
  end
end
