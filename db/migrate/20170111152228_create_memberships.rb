class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.references :user, foreign_key: true
      t.string :role
      t.integer :project_id
      t.string :project_name
      t.integer :project_owner_id
      t.string :local_access

      t.timestamps
    end
  end
end
