class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :check_token!, :init_session_per_page

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to root_url, :alert => exception.message }
    end
  end
  
  rescue_from OAuth2::Error do |exception|
    if exception.response.status == 401
      session[:user_id] = nil
      session[:access_token] = nil

      redirect_to root_url, alert: "Access token expired, try signing in again."
    end
  end
  
  def init_session_per_page
    session[:per_page] ||= 50
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

  def current_user_access_data
    access_token.get("/api/me").parsed if current_user && access_token
  end

  def current_user_write_abilities
    @current_user_write_abilities = (current_user && access_token) ? access_token.get("/api/my/authorizations/write").parsed.select{|p| p['uid'].include?(Rails.application.secrets.client_id) } : []
  end
  helper_method :current_user_write_abilities

  def current_user_read_abilities
    @current_user_read_abilities = (current_user && access_token) ? access_token.get("/api/my/authorizations/read").parsed : []
  end
  helper_method :current_user_read_abilities
 
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
