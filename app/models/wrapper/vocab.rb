module Wrapper
  class Vocab

    def self.search(q, access_token)
      resp = JSON.parse(access_token.get("/v1/search/concepts.json?q=#{CGI.escape(q)}&in_scheme=#{Rails.application.secrets.in_scheme}").body)['concepts']
      data = resp.map{|t| 
        default_name = t['prefLabel'].try('[]', 'de') || t['prefLabel'].try('[]', 'en') || 'unknown language'
        { 
          value: t.to_json, 
          # value: [t['default_label'], t['id'].to_s, t['html_url']].join(';'),
          name: default_name, 
          parents: t['broader'].map{|b| b['prefLabel'].try(:values).join(', ') }.join(', '), 
          note: t['definition'].try(:values).join(', '), 
          labels: t['prefLabel'].try(:values).push(t['altLabel'].try(:values)).push(t['hiddenLabel'].try(:values)).compact.join(', ')
        }
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