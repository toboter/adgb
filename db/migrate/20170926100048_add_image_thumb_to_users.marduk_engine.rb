# This migration comes from marduk_engine (originally 20170926095812)
class AddImageThumbToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :image_thumb_url, :string
  end
end
