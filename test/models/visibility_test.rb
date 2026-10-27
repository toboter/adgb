require "test_helper"

class VisibilityTest < ActiveSupport::TestCase
  setup do
    @artefact = artefacts(:one)
    @owner = users(:one)
    @other = users(:two)
  end

  test "visible_for anonymous builds EXISTS subquery without raising" do
    sql = nil
    assert_nothing_raised do
      sql = Artefact.visible_for(nil).to_sql
    end

    assert_match(/EXISTS/i, sql)
    assert_match(/publish/i, sql)
  end

  test "visible_for with user builds EXISTS for sharings and create events" do
    sql = nil
    assert_nothing_raised do
      sql = Artefact.visible_for(@owner).to_sql
    end

    assert_match(/EXISTS/i, sql)
    assert_match(/share_models/i, sql)
  end

  test "visible_for returns an ActiveRecord::Relation" do
    assert_kind_of ActiveRecord::Relation, Artefact.visible_for(nil)
  end

  test "anonymous sees only published locked artefacts" do
    assert_not_includes Artefact.visible_for(nil), @artefact

    publish_record!(@artefact, user: @owner)
    assert_includes Artefact.visible_for(nil), @artefact
  end

  test "creator sees own unpublished artefact via create version" do
    create_record_version!(@artefact, event: "create", user: @owner)
    assert_includes Artefact.visible_for(@owner), @artefact
    assert_not_includes Artefact.visible_for(@other), @artefact
  end

  test "shared user sees artefact via share_models" do
    ShareModel.create!(
      resource: @artefact,
      shared_to: @other,
      shared_from: @owner,
      edit: false
    )
    assert_includes Artefact.visible_for(@other), @artefact
  end

  test "published? requires locked and last publish event" do
    assert_not @artefact.published?
    publish_record!(@artefact, user: @owner)
    assert @artefact.reload.published?
  end
end
