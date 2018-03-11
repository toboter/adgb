class AddTextSolutionToArtefact < ActiveRecord::Migration[5.1]
  def change
    add_column :artefacts, :text_solution, :string
    rename_column :artefacts, :abguss, :zeichnung
  end
end
