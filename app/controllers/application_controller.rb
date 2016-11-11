class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :check_token!
  
  rescue_from OAuth2::Error do |exception|
    if exception.response.status == 401
      session[:user_id] = nil
      session[:access_token] = nil

      redirect_to root_url, alert: "Access token expired, try signing in again."
    end
  end

private

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(Rails.application.secrets.client_id, 
      Rails.application.secrets.client_secret, 
      site: Rails.application.secrets.provider_site)
  end

  def access_token
    @access_token ||= OAuth2::AccessToken.new(oauth_client, session[:access_token]) if session[:access_token]
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  
  def authorize
    redirect_to root_url, alert: "Not authorized. Please sign in." if current_user.nil?
  end
  
  # The current_user is logged out automatically and redirected to root if the access_token is expired.
  def check_token!
    if current_user && access_token && access_token.expired?
      session[:user_id] = nil
      session[:access_token] = nil
      
      redirect_to root_url, notice: 'Access token expired. You have been logged out.'
    end
  end 
end
