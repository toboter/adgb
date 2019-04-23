module Wrapper
  class Vocab

    def self.search(q, access_token)
      # die unterschiedlichen Sprachen werden ausgefiltert.
      resp = JSON.parse(access_token.get("/v1/search/concepts.json?q=#{CGI.escape(q)}&in_scheme=#{Rails.application.secrets.in_scheme}").body)['concepts']
      data = resp.map{|t| { 
        value: t.to_json, 
        # value: [t['default_label'], t['id'].to_s, t['html_url']].join(';'),
        name: t['default_label'], 
        parents: t['broader'].map{|b| b['default_label'] }.join(', '), 
        note: t['notes'].first['body'], 
        labels: t['labels'].map{|l| l['body'] }.join(', ') }
      }
      return data
    end

    def self.find(uuid, access_token)
      resp = JSON.parse(access_token.get("/v1/babylon-basis/vocab/schemes/#{Rails.application.secrets.in_scheme}/concepts/#{uuid}.json").body)['concept']
      data = resp
      return data
    end
  end
end