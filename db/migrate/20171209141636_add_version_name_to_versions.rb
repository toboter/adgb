class AddVersionNameToVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :versions, :version_name, :string
    add_column :versions, :changed_characters_length, :integer
    add_column :versions, :total_characters_length, :integer
  end
end
