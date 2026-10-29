require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should get api" do
    skip "Home#api depends on live credentials/provider config in this environment"
  end
end

