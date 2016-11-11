class CreateArtefacts < ActiveRecord::Migration[5.0]
  def change
    create_table :artefacts do |t|
      t.string :bab_rel
      t.string :grabung
      t.integer :bab
      t.string :bab_ind
      t.string :b_join
      t.string :b_korr
      t.string :mus_sig
      t.integer :mus_nr
      t.string :mus_ind
      t.string :m_join
      t.string :m_korr
      t.string :kod
      t.string :grab
      t.string :text
      t.string :sig
      t.integer :diss
      t.integer :mus_id
      t.string :standort_alt
      t.string :standort
      t.string :mas1
      t.string :mas2
      t.string :mas3
      t.text :f_obj
      t.string :abklatsch
      t.string :abguss
      t.string :fo_tell
      t.string :fo1
      t.string :fo2
      t.string :fo3
      t.string :fo4
      t.text :fo_text
      t.integer :UTMx
      t.integer :UTMxx
      t.integer :UTMy
      t.integer :UTMyy
      t.text :inhalt
      t.string :period
      t.string :arkiv
      t.string :text_in_archiv
      t.string :jahr
      t.string :datum
      t.string :zeil2
      t.string :zeil1

      t.timestamps
    end
    add_index(:artefacts, :bab_rel, unique: true)
  end
end
