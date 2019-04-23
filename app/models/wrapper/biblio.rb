module Wrapper
  class Biblio

    def self.search(q, access_token)
      resp = JSON.parse(access_token.get("/v1/bibliography/entries.json?q=#{CGI.escape(q)}").body)['entries']
      data = resp.map{|e| e.merge(value: e.to_json)}
      return data
    end

  end
end