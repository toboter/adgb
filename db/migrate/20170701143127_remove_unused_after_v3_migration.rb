class RemoveUnusedAfterV3Migration < ActiveRecord::Migration[5.0]
  def change
    remove_column :artefacts, :creator_id, :integer
    remove_column :users, :scope, :string
    drop_table :accessibilities
  end
end
