class SearchController < ApplicationController
  def index
    query = params[:search]
    source_ids = Source.visible_for(current_user).all.ids
    artefact_ids = Artefact.visible_for(current_user).all.ids

    @results = Searchkick.search(query,
        index_name: [Source, Artefact],
        where: { _or:
          [
            {
              _index: Source.search_index.name,
              id: source_ids
            },
            {
              _index: Artefact.search_index.name,
              id: artefact_ids
            }
          ]
        },
        fields: [:default_fields],
        misspellings: {below: 1}
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end

    @pagy, @search_results = pagy(:offset, @results.to_a, limit: session[:per_page])
  end
end
