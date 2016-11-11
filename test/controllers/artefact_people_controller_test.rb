require 'test_helper'

class ArtefactPeopleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get artefact_people_index_url
    assert_response :success
  end

end
