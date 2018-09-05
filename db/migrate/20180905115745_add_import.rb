class AddImport < ActiveRecord::Migration[5.2]
  def change
    create_table :imports do |t|
      t.string  :name
      t.jsonb   :data
      t.integer :creator_id, index: true

      t.timestamps
    end
    add_index :imports, :data, using: :gin
  end
end
