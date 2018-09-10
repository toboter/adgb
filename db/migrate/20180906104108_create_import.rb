class CreateImport < ActiveRecord::Migration[5.2]
  def change
    rename_table  :imports, :import_events
    remove_column :import_events, :data, :jsonb
    add_column    :import_events, :sheets_count, :integer

    create_table :import_sheets do |t|
      t.integer  :event_id, index: true
      t.string   :name
      t.integer  :rows_count
      t.integer  :headers_count
      t.string   :model_mapping
    end

    create_table :import_headers do |t|
      t.integer  :sheet_id, index: true
      t.string   :name
      t.string   :attribute_mapping
    end

  end
end
