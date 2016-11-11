require 'test_helper'

class ImportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get imports_index_url
    assert_response :success
  end

  test "should get artefacts" do
    get imports_artefacts_url
    assert_response :success
  end

  test "should get artefact_references" do
    get imports_artefact_references_url
    assert_response :success
  end

  test "should get artefact_photos" do
    get imports_artefact_photos_url
    assert_response :success
  end

  test "should get artefact_people" do
    get imports_artefact_people_url
    assert_response :success
  end

  test "should get photos" do
    get imports_photos_url
    assert_response :success
  end

end
