class Api::V1::BaseController < ActionController::API
  require 'rest-client'
  require 'json'

  before_action :set_token, :set_user


  def pagination_dict(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.previous_page,
      total_pages: collection.total_pages,
      total_count: collection.total_entries
    }
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(Rails.application.secrets.client_id, 
      Rails.application.secrets.client_secret, 
      site: Rails.application.secrets.provider_site)
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