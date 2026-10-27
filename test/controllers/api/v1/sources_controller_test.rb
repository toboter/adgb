require "test_helper"

class Api::V1::SourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @source = sources(:one)
    publish_record!(@source)
  end

  test "api index returns serializer-shaped json" do
    get "/api/sources", as: :json

    assert_response :success
    body = JSON.parse(response.body)

    assert body.key?("sources"), "expected sources root, got: #{body.keys.inspect}"
    assert body["sources"].is_a?(Array)
    assert body.key?("meta")
    assert body["meta"].key?("current_page")

    first = body["sources"].find { |row| row["id"] == @source.slug } || body["sources"].first
    assert first, "expected at least one source in index"
    assert_source_contract(first)
  end

  test "api show returns nested source contract" do
    get "/api/sources/#{@source.slug}", as: :json

    assert_response :success
    body = JSON.parse(response.body)

    assert body.key?("source")
    assert_source_contract(body["source"])
    assert_equal @source.slug, body["source"]["id"]
    assert body["source"].key?("callNumber")
    assert body["source"]["callNumber"].key?("value")
  end

  private

  def assert_source_contract(row)
    assert row.key?("id")
    assert row.key?("serialNumber")
    assert row.key?("callNumber")
    assert row.key?("title")
    assert row.key?("links")
    assert row["links"].key?("self")
    assert row.key?("published?")
    assert row.key?("full_entry")
  end
end
