class SessionsController < ApplicationController
  require 'rest-client'
  after_action :update_user, only: :create

  def create
    auth = request.env["omniauth.auth"]
    token = auth["credentials"]["token"]

    user = User.where(provider: auth["provider"], uid: auth["uid"]).first_or_create! do |u|
      u.regenerate_token
      @new_user = true
    end

    session[:access_token] = auth["credentials"]["token"]
    session[:user_id] = user.id
    redirect_to (session[:user_return_to] || request.env['omniauth.origin'] || root_url), notice: "You have been signed in through #{user.provider.humanize}."
    session[:user_return_to] = nil
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil
    session[:per_page] = nil

    redirect_to root_url, notice: "Bye!"
  end
  
  def set_per_page
    session[:per_page] = params[:per_page].to_i
    redirect_back(fallback_location: root_path)
  end

  private
  def update_user
    puts 'updating user'
    user = User.find(session[:user_id])
    babili_user = JSON.parse(access_token.get('/api/user').body, object_class: OpenStruct)
    babili_accessibilities = JSON.parse(access_token.get("/api/authorizations/clients/#{Rails.application.secrets.client_id}").body, object_class: OpenStruct)

    babili_accessibilities.project_accessors.each do |project|
      group = Group.where(gid: project.id, provider: 'babili').first_or_create! do |g|
        g.name = project.name
      end
      group.users = User.where(uid: project.member_ids, provider: 'babili')
    end

    user.app_admin = babili_accessibilities.user_permissions.extra.manage
    user.app_creator = babili_accessibilities.user_permissions.create
    user.app_publisher = babili_accessibilities.user_permissions.extra.publish
    user.app_commentator = babili_accessibilities.user_permissions.extra.comment
   
    user.email = babili_user.email
    user.name = babili_user.display_name
    user.image_thumb_url = babili_user.image_thumb_50
    
    flash[:success] = 'User info and permissions updated' if user.save
    set_local_token_on_babili if @new_user.present?
  end

  def set_local_token_on_babili
    puts 'sending token'
    # adding the initial token to each repo in babili when signing up the first time start
    repos = JSON.parse(access_token.get("/api/repositories/resources/#{Rails.application.secrets.host_id}").body, object_class: OpenStruct)

    if repos.any? && current_user.regenerate_token
      begin
        repos.each do |r|
          data = {token: current_user.token, token_type: 'Token'}
          resp = access_token.post("/api/repositories/#{r.id}/tokens", body: data)
          flash[:notice] = (resp.status == 201 ? "Token received." : 'An error occured.')
        end
      rescue RestClient::ExceptionWithResponse => e
        flash[:alert] = "The Server ist returning #{e}. Token not sent."
      end
    else
      flash[:alert] = "Token not created. #{'No repositories found.' if !repos.any?}"
    end
    # This can also be done through the adgb/settings page manually.
    # adding token to babili end
  end
end