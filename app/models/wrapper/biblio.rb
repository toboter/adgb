module Wrapper
  class Biblio

    def self.search(q, access_token)
      resp = JSON.parse(access_token.get("/v1/bibliography/entries.json?q=#{CGI.escape(q)}").body)['citation_data_items']
      data = resp.map{|e| e.merge(value: e.to_json)}
      return data
    end

    def self.find(url, access_token)
      url = url.gsub('babylon-online.org', 'dev.local:3000') if Rails.env != 'production'
      resp = JSON.parse(access_token.get(url).body)['citation_data_item']
      data = resp
      return data
    end
  end
end
