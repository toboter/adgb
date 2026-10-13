require "test_helper"

class Api::V1::ArtefactsControllerTest < ActionDispatch::IntegrationTest
  test "api index returns serializer-shaped json" do
    get "/api/artefacts", as: :json

    assert_response :success
    body = JSON.parse(response.body)

    assert body.key?("artefacts"), "expected artefacts root, got: #{body.keys.inspect}"
    assert body["artefacts"].is_a?(Array)
    assert body.key?("meta")
    assert body["meta"].key?("current_page")
  end
end
