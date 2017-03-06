class UsersController < ApplicationController
  require 'rest-client'
  before_action :authorize
  
  def show
  end

  def edit
  end

  def update
    if current_user.update(user_params)
      redirect_to user_url, notice: 'You successfully updated.'
    else
      render :edit
    end
  end

  def add_token_to_babili
    current_user.regenerate_token if current_user
    if current_user && current_user.token.present?
      url = "#{Rails.application.secrets.provider_site}/api/oread_application_access_token"
      host = request.base_url
      begin
        response = RestClient.post url, {token: current_user.token, host: host}, {:Authorization => "Bearer #{access_token.token}"}
        redirect_to user_url, notice: response.code == 200 ? 'Token sent.' : 'An error occured.'
      rescue RestClient::ExceptionWithResponse => e
        redirect_to user_url, alert: "The Server ist returning #{e}. Perhaps you are not assigned to any projects. Service Token for babili not sent."
      end
    else
      redirect_to user_url, alert: 'Something went wrong.'
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:token)
    end

end