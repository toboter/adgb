class AddIdAndUrlToTags < ActiveRecord::Migration[5.1]
  def change
    add_column :tags, :uuid, :string
    add_column :tags, :url, :string
  end
end
