# This migration comes from enki_engine (originally 20170612100530)
class CreateShareableModel < ActiveRecord::Migration[5.0]
  def change
    create_table :share_models do |t|
      # Sahred resource
      t.references :resource, polymorphic: true, index: true
      # Model who will receive resource
      t.references :shared_to, polymorphic: true, index: true
      # Model who share the resource
      t.references :shared_from, polymorphic: true, index: true
      # Edit permissions
      t.boolean :edit

      t.timestamps
    end
    add_index :share_models, [:resource_id, :resource_type, :shared_to_id, :shared_to_type], name: 'index_share_models_on_resource_and_shared_to', unique: true 
  end
end
