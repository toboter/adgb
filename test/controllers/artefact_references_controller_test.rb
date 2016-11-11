require 'test_helper'

class ArtefactReferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get artefact_references_index_url
    assert_response :success
  end

end
