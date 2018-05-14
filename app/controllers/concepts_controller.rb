class ConceptsController < ApplicationController

  def search
    query = params[:q]
    resp = JSON.parse(access_token.get("/api/search/concepts.json?q=#{query}").body)['concepts']
    data = resp.map{|t| { value: [t['default_label'], t['id'].to_s, t['html_url']].join(';'), name: t['default_label'], parents: t['broader'].map{|b| b['default_label'] }.join(', '), note: t['notes'].first['body'] } }
    render json: data
  end

end