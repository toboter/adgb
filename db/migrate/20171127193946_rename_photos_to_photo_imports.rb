class RenamePhotosToPhotoImports < ActiveRecord::Migration[5.0]
  def up
    rename_table :photos, :photo_imports
    ShareModel.where(resource_type: 'Photo').update_all(resource_type: 'PhotoImport')
    RecordActivity.where(resource_type: 'Photo').update_all(resource_type: 'PhotoImport')
  end

  def down
    rename_table :photo_imports, :photos
    ShareModel.where(resource_type: 'PhotoImport').update_all(resource_type: 'Photo')
    RecordActivity.where(resource_type: 'PhotoImport').update_all(resource_type: 'Photo')
  end
end
