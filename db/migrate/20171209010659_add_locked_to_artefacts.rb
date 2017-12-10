class AddLockedToArtefacts < ActiveRecord::Migration[5.1]
  def change
    add_column :artefacts, :locked, :boolean, null: false, default: false
  end
end
