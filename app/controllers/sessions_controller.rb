class SessionsController < ApplicationController
  require 'rest-client'

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth["provider"], uid: auth["uid"]).first_or_create! do |u|
      u.token = auth["credentials"]["token"]

      # adding the initial token to the search feature in babili
      url = "#{Rails.application.secrets.provider_site}/api/oread_application_access_token"
      host = request.base_url
      begin
        response = RestClient.post url, {token: u.token, host: host}, {:Authorization => "Bearer #{u.token}"}
      rescue RestClient::ExceptionWithResponse => e
        flash[:alert] = "The Server ist returning #{e}. Perhaps you are not assigned to any projects. Service Token for babili not sent."
      end

    end
    session[:user_id] = user.id
    session[:access_token] = auth["credentials"]["token"]
    write_authorization = current_user_write_abilities.to_s.include?(Rails.application.secrets.client_id) ? 'write' : nil
    user.update(
      email: auth["info"]["email"], 
      name: auth["info"]["name"], 
      gender: auth["info"]["gender"], 
      birthday: auth["info"]["birthday"],
      scope: write_authorization)


    redirect_to (request.env['omniauth.origin'] || root_url), notice: "You have been signed in through #{user.provider.humanize}."
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil

    redirect_to root_url, notice: "Bye!"
  end
  
  def set_per_page
    session[:per_page] = params[:per_page].to_i
    redirect_to :back
  end
end





#     projects = access_token.get("/api/projects").parsed if current_user && access_token
#     if projects
#       app_projects = projects.select{|p| p['accessibilities'].map{|a| a['oauth_uid']}.include?(Rails.application.secrets.client_id) }
#       app_projects.each do |p_project|
#         project = Project.where(babili_project_id: p_project['id'].to_i).first_or_create!
#         project.update(
#           babili_project_name: p_project['name'],
#           published: p_project['data_published'],
#           local_access: p_project['accessibilities'].select{|a| a['oauth_uid'] == Rails.application.secrets.client_id}.first['access'])
#         p_project['memberships'].each do |member|
#           user = User.where(uid: member['user_id'], provider: member['provider']).first_or_create!
#           membership = project.memberships.where(user_id: user, project_id: project).first_or_create!
#           membership.update(role: member['role'])
#           project.update(owner_id: user.id) if member['role'] == 'Owner'
#         end
#       end
#     end