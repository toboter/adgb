class SearchController < ApplicationController

  def index
    query = params[:search]

    # https://github.com/ankane/searchkick/issues/951
    #elasticsearch multi search, group into a single set of search_results
    indices = [Source, Artefact]
    search_batch = batch_multiple_searches(query, indices)
    Searchkick.multi_search(search_batch)
    
    results = []
    search_batch.each do |search_results_per_model|
      # skip if response is nil (a nil response can happen with a missing index)
      # no results would return [] for hits
      next if search_results_per_model.response['hits'].nil?

      # searchkick delegate to_arr to the results, and would return and array of active records
      # objects matching the search
      results.concat(search_results_per_model) #.response['hits']['hits'])
      # results.sort_by! { |r| r['_score'] }.reverse!
    end


    @search_results = results #.paginate(:page => params[:page], :per_page => session[:per_page])
  end

  def batch_multiple_searches(term, indices)
    indices.map do |index|
      #index_ids = index.visible_for(current_user).ids
      index.search(term, execute: false) #, where: {id: index_ids}
    end
  end

end

