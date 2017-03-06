class CreateAccessibilities < ActiveRecord::Migration[5.0]
  def change
    create_table :accessibilities do |t|
      t.references :accessable, polymorphic: true
      t.integer :project_id

      t.timestamps
    end
  end
end
