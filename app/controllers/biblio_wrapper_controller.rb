class BiblioWrapperController < ApplicationController

  def search
    query = params[:q]
    resp = JSON.parse(access_token.get("/v1/bibliography/entries.json?q=#{CGI.escape(query)}").body)['entries']
    data = resp.map{|e| e.merge(value: e.to_json)}
    render json: data.to_json
  end

end