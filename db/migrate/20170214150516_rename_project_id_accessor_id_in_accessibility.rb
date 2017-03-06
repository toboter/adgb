class RenameProjectIdAccessorIdInAccessibility < ActiveRecord::Migration[5.0]
  def change
    rename_column :accessibilities, :project_id, :accessor_id
    add_column :accessibilities, :scope, :string
    add_column :accessibilities, :creator_id, :integer
  end
end
