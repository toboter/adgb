require 'omniauth/strategies/babili'

# OmniAuth >= 2.2: reject forged Host / X-Forwarded-Host on callback URLs (CVE-2026-63183).
OmniAuth.config.allowed_hosts = [
  /\A([a-z0-9-]+\.)?babylon-online\.org\z/i,
  "localhost",
  "127.0.0.1",
  /\A.+\.dev\.local\z/i
]

Rails.application.config.middleware.use OmniAuth::Builder do
  # Use the system CA store (Let's Encrypt etc.). Do not point at a missing
  # cacert.pem — OpenSSL then fails with SSL_CTX_load_verify_file / BIO lib.
  provider :babili,
    Rails.application.credentials.client_id,
    Rails.application.credentials.client_secret,
    scope: "public write"
end