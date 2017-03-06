class DropProjectAndMembershipTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :memberships
    drop_table :projects
  end
end
