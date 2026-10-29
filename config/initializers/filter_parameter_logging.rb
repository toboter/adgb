# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password,
  :password_confirmation,
  :secret,
  :token,
  :_key,
  :crypt,
  :salt,
  :certificate,
  :otp,
  :ssn,
  :access_token,
  :refresh_token,
  :client_secret,
  :authenticity_token,
  :git_token
]
