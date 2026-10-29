# Searchkick reads OPENSEARCH_URL.
#
# Operating model for this platform: OpenSearch runs on the same host as the
# app (localhost), over plain HTTP. TLS/SSL is not required and not used.
# Do not expose OpenSearch on a public interface.
#
# Resolution order:
#   1. ENV["OPENSEARCH_URL"]
#   2. Rails.application.credentials.opensearch_url
#   3. http://localhost:9200
#
# Example (local / production on same host):
#   opensearch_url: http://localhost:9200

if ENV["OPENSEARCH_URL"].blank?
  from_credentials = Rails.application.credentials.opensearch_url rescue nil
  ENV["OPENSEARCH_URL"] = from_credentials.to_s if from_credentials.present?
end

ENV["OPENSEARCH_URL"] ||= "http://localhost:9200"

# Only if an HTTPS URL is configured explicitly (unusual for this deploy).
if ENV["OPENSEARCH_URL"].start_with?("https://")
  Searchkick.client_options = {
    transport_options: {
      ssl: { verify: false }
    }
  }
end
