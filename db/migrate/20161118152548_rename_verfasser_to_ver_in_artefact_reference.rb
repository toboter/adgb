class RenameVerfasserToVerInArtefactReference < ActiveRecord::Migration[5.0]
  def change
    rename_column :artefact_references, :verfasser, :ver
  end
end
