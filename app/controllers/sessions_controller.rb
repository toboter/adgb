class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth["provider"], uid: auth["uid"]).first_or_create!
    user.update(email: auth["info"]["email"], name: auth["info"]["name"], gender: auth["info"]["gender"], birthday: auth["info"]["birthday"])
    session[:user_id] = user.id
    session[:access_token] = auth["credentials"]["token"]

    redirect_to root_url, notice: "You have been signed in through #{user.provider.humanize}."
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil

    redirect_to root_url, notice: "Bye!"
  end
end