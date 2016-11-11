class CreateArtefactPhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :artefact_photos do |t|
      t.string :p_bab_rel
      t.string :ph
      t.integer :ph_nr
      t.string :ph_add
      t.string :position
      t.string :p_rel

      t.timestamps
    end
    add_index :artefact_photos, :p_bab_rel
    add_index :artefact_photos, :p_rel
  end
end
