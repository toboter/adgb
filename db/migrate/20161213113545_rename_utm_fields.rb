class RenameUtmFields < ActiveRecord::Migration[5.0]
  def change
    rename_column :artefacts, :UTMx, :utmx
    rename_column :artefacts, :UTMxx, :utmxx
    rename_column :artefacts, :UTMy, :utmy
    rename_column :artefacts, :UTMyy, :utmyy
  end
end