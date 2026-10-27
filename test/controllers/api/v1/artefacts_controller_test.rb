require "test_helper"

class Api::V1::ArtefactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @artefact = artefacts(:one)
    publish_record!(@artefact)
  end

  test "api index returns serializer-shaped json" do
    get "/api/artefacts", as: :json

    assert_response :success
    body = JSON.parse(response.body)

    assert body.key?("artefacts"), "expected artefacts root, got: #{body.keys.inspect}"
    assert body["artefacts"].is_a?(Array)
    assert body.key?("meta")
    assert body["meta"].key?("current_page")

    first = body["artefacts"].find { |row| row["id"] == @artefact.slug } || body["artefacts"].first
    assert first, "expected at least one artefact in index"
    assert_artefact_contract(first)
  end

  test "api show returns nested artefact contract" do
    get "/api/artefacts/#{@artefact.slug}", as: :json

    assert_response :success
    body = JSON.parse(response.body)

    assert body.key?("artefact")
    assert_artefact_contract(body["artefact"])
    assert_equal @artefact.slug, body["artefact"]["id"]
  end

  private

  def assert_artefact_contract(row)
    assert row.key?("id")
    assert row.key?("identification")
    assert row["identification"].key?("excavationNumber")
    assert row["identification"].key?("collectionNumber")
    assert row.key?("excavationUnit")
    assert row["excavationUnit"].key?("geometry")
    assert row.key?("links")
    assert row["links"].key?("self")
    assert row["links"].key?("html")
    assert row.key?("published?")
    assert row.key?("full_entry")
  end
end
