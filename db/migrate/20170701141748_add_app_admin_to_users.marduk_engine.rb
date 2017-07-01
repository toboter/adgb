# This migration comes from marduk_engine (originally 20170607075200)
class AddAppAdminToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :app_admin, :boolean
  end
end
