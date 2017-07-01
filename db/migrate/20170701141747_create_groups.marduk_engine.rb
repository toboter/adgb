# This migration comes from marduk_engine (originally 20170606125957)
class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :provider
      t.string :gid

      t.timestamps
    end
  end
end
