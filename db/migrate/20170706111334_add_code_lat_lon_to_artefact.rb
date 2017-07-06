class AddCodeLatLonToArtefact < ActiveRecord::Migration[5.0]
  def change
    add_column :artefacts, :code, :string
    add_column :artefacts, :latitude, :float
    add_column :artefacts, :longitude, :float
  end
end
