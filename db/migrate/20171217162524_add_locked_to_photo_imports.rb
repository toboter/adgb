class AddLockedToPhotoImports < ActiveRecord::Migration[5.1]
  def change
    add_column :photo_imports, :locked, :boolean, default: false, null: false
  end
end
