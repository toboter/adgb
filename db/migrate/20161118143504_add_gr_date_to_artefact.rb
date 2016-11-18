class AddGrDateToArtefact < ActiveRecord::Migration[5.0]
  def change
    add_column :artefacts, :gr_datum, :string
    add_column :artefacts, :gr_jahr, :string
  end
end
