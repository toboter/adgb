class ChangeSourcesModelToExcelModel < ActiveRecord::Migration[5.1]
  def change
    PaperTrail::Version.where(item_type: 'Source').destroy_all
    ShareModel.where(resource_type: 'Source').destroy_all
    drop_table :sources
    create_table :sources do |t|
      t.integer   :archive_id, index: true
      t.string    :collection, index: true
      t.string    :call_number, index: true
      t.string    :temp_call_number
      t.integer   :parent_id, index: true
      t.string    :sheet
      t.string    :type
      t.string    :genuineness
      t.string    :material
      t.string    :measurements
      t.string    :title
      t.string    :labeling
      t.string    :provenance
      t.string    :period
      t.string    :author
      t.string    :size
      t.string    :contains
      t.string    :part_of
      t.string    :description
      t.string    :remarks
      t.string    :condition
      t.string    :access_restrictions
      t.string    :loss_remarks
      t.string    :location_current
      t.string    :location_history
      t.string    :state
      t.text      :history
      t.string    :relevanze
      t.string    :relevanze_comment
      t.string    :digitize_remarks
      t.string    :keywords
      t.string    :links
      t.string    :slug, index: true

      t.timestamps
    end
  end
end