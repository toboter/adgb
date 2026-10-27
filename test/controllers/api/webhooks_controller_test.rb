require "test_helper"

class Api::WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update_columns(provider: "babili", uid: "webhook-uid-1", app_admin: false, app_creator: false)
  end

  test "update_user_accessibilities syncs permissions from babili" do
    user_payload = { "user" => { "id" => "webhook-uid-1", "display_name" => "Hook User" } }.to_json
    access_payload = {
      "application_authorization_client" => {
        "organization_accessors" => [
          { "id" => "org-1", "name" => "Org One", "member_ids" => ["webhook-uid-1"] }
        ],
        "user_permissions" => {
          "create" => true,
          "extra" => { "manage" => true, "publish" => true, "comment" => false }
        }
      }
    }.to_json

    responses = [
      OpenStruct.new(body: user_payload),
      OpenStruct.new(body: access_payload)
    ]

    with_stubbed_method(RestClient, :get, returns: ->(*) { responses.shift }) do
      get "/api/hooks/update_accessibilities", params: { access_token: "hook-token" }, as: :json
    end


    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "updated", body["message"]

    @user.reload
    assert @user.app_admin
    assert @user.app_creator
    assert @user.app_publisher
    assert_not @user.app_commentator
    assert Group.exists?(gid: "org-1", provider: "babili")
  end
end
