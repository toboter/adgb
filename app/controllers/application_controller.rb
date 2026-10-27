class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true

  before_action :check_token!
  before_action :init_session_per_page
  before_action :set_paper_trail_whodunnit

#  around_action :set_current_user

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
    status = exception.response&.status
    if status == 401
      session[:user_id] = nil
      session[:access_token] = nil

      redirect_to root_url, alert: "Access token expired, try signing in again."
    else
      redirect_back fallback_location: root_url,
                    alert: "Babili API error (#{status || 'unknown'}): #{exception.message.to_s.truncate(200)}"
    end
  end

  helper_method :current_user

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

#  def set_current_user
#    User.current = current_user
#    yield
#  ensure
#    # to address the thread variable leak issues in Puma/Thin webserver
#    User.current = nil
#  end

  helper_method :current_user_repos

  def init_session_per_page
    session[:per_page] ||= 50
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(Rails.application.credentials.client_id,
      Rails.application.credentials.client_secret,
      site: Rails.application.credentials.provider_site)
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

  # Babili still exposes enrolled collections at GET /v1/user/repositories
  # (returns CollectionSerializer). Token registration uses /v1/collections.
  def current_user_repos
    @current_user_repos =
      if current_user && access_token
        parse_babili_json(access_token.get("/v1/user/repositories").body)
      else
        []
      end
  end

  # Babili AMS :json responses are root-wrapped ({"user": {...}} / {"collections": [...]}).
  # Unwrap a single root key and deep-convert to OpenStruct for existing callers.
  def parse_babili_json(body)
    data = body.present? ? JSON.parse(body) : nil
    return [] if data.nil?

    if data.is_a?(Hash) && data.keys.size == 1 && !data.key?("meta")
      data = data.values.first
    end
    deep_ostruct(data)
  end

  def deep_ostruct(node)
    case node
    when Hash
      OpenStruct.new(node.transform_values { |value| deep_ostruct(value) })
    when Array
      node.map { |value| deep_ostruct(value) }
    else
      node
    end
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
