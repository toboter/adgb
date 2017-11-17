class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Marduk

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

end
