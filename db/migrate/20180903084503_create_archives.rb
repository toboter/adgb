class CreateArchives < ActiveRecord::Migration[5.1]
  def change
    create_table :archives do |t|
      t.string :name
      t.integer :sources_count

      t.timestamps
    end
  end
end
