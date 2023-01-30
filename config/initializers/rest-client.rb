require 'rest-client'
RestClient.proxy = Rails.application.secrets.proxy ||= nil
