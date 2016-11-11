class CreateArtefactReferences < ActiveRecord::Migration[5.0]
  def change
    create_table :artefact_references do |t|
      t.string :verfasser
      t.string :publ
      t.string :jahr
      t.string :seite
      t.string :b_bab_rel
      t.string :ph_rel

      t.timestamps
    end
    add_index(:artefact_references, :b_bab_rel)
    add_index(:artefact_references, :ph_rel)
  end
end
