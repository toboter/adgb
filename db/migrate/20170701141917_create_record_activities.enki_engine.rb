# This migration comes from enki_engine (originally 20170614132711)
class CreateRecordActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :record_activities do |t|
      t.integer :actor_id
      t.references :resource, polymorphic: true, index: true
      t.string :activity_type

      t.timestamps
    end
    add_index :record_activities, [:resource_id, :resource_type, :activity_type], name: 'index_record_activities_on_resource_and_activity', unique: true 
  end
end
