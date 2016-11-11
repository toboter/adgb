class CreateArtefactPeople < ActiveRecord::Migration[5.0]
  def change
    create_table :artefact_people do |t|
      t.string :person
      t.string :titel
      t.string :n_bab_rel

      t.timestamps
    end
    add_index :artefact_people, :n_bab_rel
  end
end
