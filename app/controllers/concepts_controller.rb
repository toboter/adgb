class ConceptsController < ApplicationController

  def search
    query = params[:q]
    resp = JSON.parse(access_token.get("/v1/search/concepts.json?q=#{query}").body)['concepts']
    data = resp.map{|t| { value: [t['default_label'], t['id'].to_s, t['html_url']].join(';'), name: t['default_label'], parents: t['broader'].map{|b| b['default_label'] }.join(', '), note: t['notes'].first['body'], labels: t['labels'].map{|l| l['body'] }.join(', ') } }
    # die unterschiedlichen Sprachen werden ausgefiltert.
    render json: data.to_json
  end

end