class SearchController < ApplicationController
  require 'will_paginate/array'

  def index
    query = params[:search]
    source_ids = Source.visible_for(current_user).all.ids
    artefact_ids = Artefact.visible_for(current_user).all.ids

    sources = Source.search(query, 
      execute: false, where: {id: source_ids})
    artefacts = Artefact.search(query, 
      execute: false, where: {id: artefact_ids})
      
    @results = Searchkick.search(query, 
      index_name: [Source, Artefact],
      where: { _or: [{ _type: Source.types.map!{|c| c.downcase.strip}, id: source_ids }, { _type: 'artefact', id: artefact_ids }]},
      misspellings: {below: 1}
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end

      @search_results = @results.to_a.paginate(per_page: session[:per_page], page: params[:page])

      @photo_results = @results.select { |result| result.try(:type) == 'Photo' }.take(10)

      @commons = current_user ? current_user_repos.detect{|s| s.name == 'Commons'} : OpenStruct.new(url: "#{Rails.application.secrets.media_host}/api/commons/search", user_access_token: nil)
      @illustrations_url = "#{@commons.url}?q=#{@photo_results.map{|i| "'#{i.name}'"}.join(' OR ')}"
      if @photo_results.any?
        begin
          response = RestClient.get(@illustrations_url, {:Authorization => "Token #{@commons.user_access_token}"})
          @files = JSON.parse(response.body)
        rescue Errno::ECONNREFUSED
          "Server at #{@commons.url} is refusing connection."
          flash.now[:notice] = "Can't connect to #{@commons.url}."
          @files = []
        end
      else 
        @files = []
      end
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