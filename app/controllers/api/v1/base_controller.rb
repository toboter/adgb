class Api::V1::BaseController < ActionController::API
  include ActionController::Helpers
  include Pagy::Method
  helper JsonSerializationHelper

  require 'json'

  before_action :set_token, :set_user

  # Preserve the historical will_paginate API meta keys for clients.
  def pagination_dict(pagy)
    {
      current_page: pagy.page,
      next_page: pagy.next,
      prev_page: pagy.previous,
      total_pages: pagy.pages,
      total_count: pagy.count
    }
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(Rails.application.credentials.client_id, 
      Rails.application.credentials.client_secret, 
      site: Rails.application.credentials.provider_site)
  end
  
  def access_token
    @access_token ||= OAuth2::AccessToken.new(oauth_client, @token) if @token
  end

  private
  def set_token
    @token = request.headers['Authorization'] ? request.headers['Authorization'].split(' ').last : params[:access_token]
  end

  def set_user
    @user = User.find_by_token(@token)
  end

end