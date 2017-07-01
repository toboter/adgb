# This migration comes from marduk_engine (originally 20170606130127)
class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.references :user, foreign_key: true
      t.references :group, foreign_key: true

      t.timestamps
    end
    add_index :memberships, [:group_id, :user_id], unique: true
  end
end
