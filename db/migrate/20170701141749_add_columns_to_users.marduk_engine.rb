# This migration comes from marduk_engine (originally 20170629224942)
class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :app_commentator, :boolean
    add_column :users, :app_creator, :boolean
    add_column :users, :app_publisher, :boolean
  end
end
