class AddSourceIdToArtefactReferences < ActiveRecord::Migration[5.1]
  def change
    add_column :artefact_references, :source_id, :integer
    add_index :artefact_references, :source_id
  end
end
