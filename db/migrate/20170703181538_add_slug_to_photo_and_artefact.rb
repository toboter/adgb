class AddSlugToPhotoAndArtefact < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :slug, :string
    add_column :artefacts, :slug, :string
    add_index :artefacts, :slug, unique: true
    add_index :photos, :slug, unique: true
  end
end
