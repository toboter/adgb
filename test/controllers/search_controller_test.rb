require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "search index renders with searchkick stubbed" do
    artefact = artefacts(:one)
    publish_record!(artefact)

    results = Object.new
    results.define_singleton_method(:to_a) { [artefact] }
    results.define_singleton_method(:total_count) { 1 }
    results.define_singleton_method(:took) { 1 }

    with_stubbed_method(Searchkick, :search, returns: results) do
      get search_path, params: { search: "fixture" }
    end

    assert_response :success
  end

  test "api artefacts search returns jbuilder shape with searchkick stubbed" do
    artefact = artefacts(:one)
    publish_record!(artefact)

    page = WillPaginate::Collection.create(1, 30, 1) { |pager| pager.replace([artefact]) }
    with_stubbed_method(Artefact, :search, returns: page) do
      get search_api_artefacts_path, params: { q: "fixture" }, as: :json
    end

    assert_response :success
    body = JSON.parse(response.body)
    assert body.key?("artefacts")
    assert body.key?("meta")
    assert_equal artefact.slug, body["artefacts"].first["id"]
  end
end
