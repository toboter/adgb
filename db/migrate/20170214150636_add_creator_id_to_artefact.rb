class AddCreatorIdToArtefact < ActiveRecord::Migration[5.0]
  def change
    add_column :artefacts, :creator_id, :integer
  end
end
