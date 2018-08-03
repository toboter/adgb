class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :check_token!
  before_action :init_session_per_page
  before_action :set_paper_trail_whodunnit

  around_action :set_current_user

  rescue_from CanCan::AccessDenied do |exception|
    session[:user_return_to] = request.path if !current_user
    exception.default_message = "You are not authorized to access this page. #{'Try to sign in!' if !current_user}"
    respond_to do |format|
      format.json { head :forbidden }
      if !current_user && params[:login] == 'true'
        format.html { redirect_to '/auth/babili', info: 'You need to sign in before continuing.' }
      else
        format.html { redirect_to root_url, :alert => exception.message }        
      end
    end
  end

  rescue_from OAuth2::Error do |exception|
    if exception.response.status == 401
      session[:user_id] = nil
      session[:access_token] = nil

      redirect_to root_url, alert: "Access token expired, try signing in again."
    end
  end

  def set_current_user
    User.current = current_user
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    User.current = nil
  end
  
  helper_method :current_user_repos

  def init_session_per_page
    session[:per_page] ||= 50
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(Rails.application.secrets.client_id, 
      Rails.application.secrets.client_secret, 
      site: Rails.application.secrets.provider_site)
  end

  def access_token
    @access_token ||= OAuth2::AccessToken.new(oauth_client, session[:access_token]) if session[:access_token]
  end
  
  def authorize
    redirect_to root_url, alert: "Not authorized. Please sign in." if current_user.nil?
  end

  def administrative
    redirect_to root_url, alert: "You need administrative priviledges." if !current_user.app_admin
  end

  def current_user_repos
    @current_user_repos = JSON.parse(((current_user && access_token) ? access_token.get("/v1/user/repositories").body : []), object_class: OpenStruct)
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
