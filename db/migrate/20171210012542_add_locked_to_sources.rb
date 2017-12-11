class AddLockedToSources < ActiveRecord::Migration[5.1]
  def change
    add_column :sources, :locked, :boolean, null: false, default: false
  end
end
