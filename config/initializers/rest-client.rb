require 'rest-client'
RestClient.proxy = Rails.application.credentials.proxy
