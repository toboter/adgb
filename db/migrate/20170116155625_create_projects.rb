class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :local_access
      t.string :babili_project_name
      t.integer :owner_id
      t.boolean :published
      t.integer :babili_project_id

      t.timestamps
    end
    remove_column :memberships, :project_name, :string
    remove_column :memberships, :project_owner_id, :integer
    remove_column :memberships, :local_access, :string
  end
end
