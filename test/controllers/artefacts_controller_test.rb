require "test_helper"

class ArtefactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @artefact = artefacts(:one)
  end

  test "should get index" do
    # Index uses Searchkick; stub so the test does not need OpenSearch.
    results = []
    results.define_singleton_method(:options) { { page: 1, per_page: 50 } }
    results.define_singleton_method(:total_count) { 0 }
    singleton = Artefact.singleton_class
    singleton.alias_method :__search_without_stub, :search
    singleton.define_method(:search) { |*| results }
    begin
      get artefacts_url
      assert_response :success
    ensure
      singleton.alias_method :search, :__search_without_stub
      singleton.remove_method :__search_without_stub
    end
  end

  test "authenticated CRUD requires session (covered by grants/visibility suites)" do
    skip "Scaffold CRUD needs OAuth session + CanCan; see grants_controller_test and visibility_test"
  end
end
