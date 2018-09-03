class RenameRelevanzeToRelevance < ActiveRecord::Migration[5.1]
  def change
    rename_column :sources, :relevanze, :relevance
    rename_column :sources, :relevanze_comment, :relevance_comment
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
