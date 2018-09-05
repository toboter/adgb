class SearchController < ApplicationController
  require 'will_paginate/array'

  def index
    query = params[:search]
    source_ids = Source.visible_for(current_user).all.ids
    artefact_ids = Artefact.visible_for(current_user).all.ids
      
    @results = Searchkick.search(query,
        index_name: [Source, Artefact],
        where: { _or: 
          [
            {
              _type: 'source', 
              id: source_ids 
            },
            {
              _type: 'artefact', 
              id: artefact_ids
            }
          ]
        },
        fields: [:default_fields],
        misspellings: {below: 1}
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end

    @search_results = @results.to_a.paginate(per_page: session[:per_page], page: params[:page])

  end

end

# def index
#   query = params[:search]
# 
#   # https://github.com/ankane/searchkick/issues/951
#   #elasticsearch multi search, group into a single set of search_results
#   indices = [Source, Artefact]
#   search_batch = batch_multiple_searches(query, indices)
#   Searchkick.multi_search(search_batch)
#   
#   results = []
#   search_batch.each do |search_results_per_model|
#     # skip if response is nil (a nil response can happen with a missing index)
#     # no results would return [] for hits
#     next if search_results_per_model.response['hits'].nil?
# 
#     # searchkick delegate to_arr to the results, and would return and array of active records
#     # objects matching the search
#     results.concat(search_results_per_model) #.response['hits']['hits'])
#     # results.sort_by! { |r| r['_score'] }.reverse!
#   end
# 
# 
#   @search_results = results #.paginate(:page => params[:page], :per_page => session[:per_page])
# end
# 
# def batch_multiple_searches(term, indices)
#   indices.map do |index|
#     index_ids = index.visible_for(current_user).all.ids
#     index.search(term, execute: false, where: {id: index_ids})
#   end
# end