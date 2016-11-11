class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.string :ph_rel
      t.string :ph
      t.integer :ph_nr
      t.string :ph_add
      t.string :ph_datum
      t.text :ph_text

      t.timestamps
    end
    add_index(:photos, :ph_rel, unique: true)
  end
end
