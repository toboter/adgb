# Searchkick reads OPENSEARCH_URL.
#
# Official OpenSearch Docker images enable HTTPS + basic auth. Plain HTTP to
# port 9200 fails with Faraday::ConnectionFailed ("end of file reached").
#
# Resolution order:
#   1. ENV["OPENSEARCH_URL"]
#   2. Rails.application.credentials.opensearch_url
#   3. https://localhost:9200 (no auth — will 401 until configured)
#
# Example credentials value:
#   opensearch_url: https://admin:YOUR_PASSWORD@localhost:9200

if ENV["OPENSEARCH_URL"].blank?
  from_credentials = Rails.application.credentials.opensearch_url rescue nil
  ENV["OPENSEARCH_URL"] = from_credentials.to_s if from_credentials.present?
end

ENV["OPENSEARCH_URL"] ||= "https://localhost:9200"

if ENV["OPENSEARCH_URL"].start_with?("https://")
  Searchkick.client_options = {
    transport_options: {
      ssl: { verify: false }
    }
  }
end

if Rails.env.development? && ENV["OPENSEARCH_URL"] !~ %r{\Ahttps://[^:/@]+:[^@/]+@}i
  warn "[opensearch] OPENSEARCH_URL has no user:password. " \
       "Set credentials.opensearch_url or ENV OPENSEARCH_URL " \
       "(https://admin:PASSWORD@localhost:9200) and restart."
end
