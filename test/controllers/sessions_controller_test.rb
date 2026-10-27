require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:babili] = OmniAuth::AuthHash.new(
      provider: "babili",
      uid: "oauth-uid-1",
      info: { name: "OAuth User", email: "oauth@example.com" },
      credentials: { token: "test-access-token", expires_at: 1.day.from_now.to_i }
    )
    SessionsController.class_eval do
      alias_method :__update_user_original, :update_user unless method_defined?(:__update_user_original)
      define_method(:update_user) { }
    end
  end

  teardown do
    OmniAuth.config.mock_auth[:babili] = nil
    OmniAuth.config.test_mode = false
    if SessionsController.method_defined?(:__update_user_original)
      SessionsController.class_eval do
        alias_method :update_user, :__update_user_original
      end
    end
  end

  test "oauth callback creates user and sets session" do
    assert_difference -> { User.where(provider: "babili", uid: "oauth-uid-1").count }, 1 do
      get "/auth/babili/callback"
    end

    assert_redirected_to root_url
    user = User.find_by!(provider: "babili", uid: "oauth-uid-1")
    assert_equal user.id, session[:user_id]
    assert_equal "test-access-token", session[:access_token]
  end

  test "signout clears session and redirects home" do
    get "/auth/babili/callback"
    assert session[:user_id].present?

    get "/signout"
    assert_redirected_to root_url
    assert_nil session[:user_id]
    assert_nil session[:access_token]
    assert_nil session[:per_page]
  end

  test "parse_babili_json unwraps single root key" do
    controller = ApplicationController.new
    result = controller.send(:parse_babili_json, '{"user":{"id":"9","display_name":"Ada"}}')
    assert_equal "9", result.id
    assert_equal "Ada", result.display_name
  end
end
