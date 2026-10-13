require 'omniauth/strategies/babili'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :babili, 
  Rails.application.credentials.client_id, 
  Rails.application.credentials.client_secret,
  {
    client_options: {
      ssl: {
        ca_file: Rails.root.join("cacert.pem").to_s
      }
    }, 
    scope: 'public write'
  }
end