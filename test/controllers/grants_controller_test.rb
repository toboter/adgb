require "test_helper"

class GrantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @owner.update_columns(app_admin: true)
    @other = users(:two)
    @artefact = artefacts(:one)
    create_record_version!(@artefact, event: "create", user: @owner)
    sign_in_as(@owner)
  end

  test "create grants read access to another user" do
    assert_difference -> { ShareModel.where(resource: @artefact, shared_to: @other).count }, 1 do
      post artefact_grants_path(@artefact), params: {
        model_name: "Artefact",
        share_to: "User,#{@other.id}",
        commit: "Allow read"
      }
    end

    assert_redirected_to @artefact
    assert_includes Artefact.visible_for(@other), @artefact
  end

  test "unauthorized user cannot grant access" do
    sign_in_as(@other)
    post artefact_grants_path(@artefact), params: {
      model_name: "Artefact",
      share_to: "User,#{@owner.id}",
      commit: "Allow read"
    }
    assert_response :redirect
    assert_equal 0, ShareModel.where(resource: @artefact, shared_to: @owner).count
  end

  test "grant_multiple inserts shares with searchkick stubbed" do
    with_stubbed_method(Artefact, :search, returns: [@artefact]) do
      post grant_multiple_artefacts_path, params: {
        model_name: "Artefact",
        accessors: ["#{@other.id} User"],
        search: "*"
      }
    end

    assert_redirected_to artefacts_path(search: "*")
    assert ShareModel.exists?(resource: @artefact, shared_to: @other)
  end



  private

  def sign_in_as(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:babili] = OmniAuth::AuthHash.new(
      provider: user.provider.presence || "babili",
      uid: user.uid.presence || "uid-#{user.id}",
      info: { name: user.name, email: user.email },
      credentials: { token: "tok-#{user.id}", expires_at: 1.day.from_now.to_i }
    )
    user.update_columns(provider: "babili", uid: OmniAuth.config.mock_auth[:babili].uid)

    SessionsController.class_eval do
      alias_method :__update_user_original, :update_user unless method_defined?(:__update_user_original)
      define_method(:update_user) { }
    end
    get "/auth/babili/callback"
  end
end
