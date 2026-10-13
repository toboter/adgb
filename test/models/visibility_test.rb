require "test_helper"

class VisibilityTest < ActiveSupport::TestCase
  test "visible_for anonymous builds EXISTS subquery without raising" do
    sql = nil
    assert_nothing_raised do
      sql = Artefact.visible_for(nil).to_sql
    end

    assert_match(/EXISTS/i, sql)
    assert_match(/publish/i, sql)
  end

  test "visible_for with user builds EXISTS for sharings and create events" do
    user = users(:one)
    sql = nil
    assert_nothing_raised do
      sql = Artefact.visible_for(user).to_sql
    end

    assert_match(/EXISTS/i, sql)
    assert_match(/share_models/i, sql)
  end

  test "visible_for returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, Artefact.visible_for(nil)
  end
end
