require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "legacy scaffold routes removed" do
    skip "users_show_url / users_edit_url were generator stubs; admin users use /admin/users"
  end
end
