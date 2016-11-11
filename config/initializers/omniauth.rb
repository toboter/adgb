require File.expand_path('lib/omniauth/strategies/babili', Rails.root)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :babili, 
  Rails.application.secrets.client_id, 
  Rails.application.secrets.client_secret, 
  {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end