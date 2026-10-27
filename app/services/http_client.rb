# Thin Faraday wrapper replacing RestClient for outbound HTTP.
class HttpClient
  DEFAULT_OPEN_TIMEOUT = 2
  DEFAULT_TIMEOUT = 8

  class << self
    def get(url, headers: {}, open_timeout: DEFAULT_OPEN_TIMEOUT, timeout: DEFAULT_TIMEOUT)
      connection(open_timeout: open_timeout, timeout: timeout).get(url) do |req|
        headers.each do |key, value|
          req.headers[key.to_s] = value.to_s if value
        end
      end
    end

    def connection(open_timeout:, timeout:)
      Faraday.new(proxy: proxy_url) do |f|
        f.options.open_timeout = open_timeout
        f.options.timeout = timeout
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end

    def proxy_url
      Rails.application.credentials.proxy.presence
    end
  end
end
