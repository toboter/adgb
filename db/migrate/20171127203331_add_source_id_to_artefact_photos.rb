class AddSourceIdToArtefactPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :artefact_photos, :source_id, :integer
  end
end
