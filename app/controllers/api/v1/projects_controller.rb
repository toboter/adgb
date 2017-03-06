class Api::V1::ProjectsController < ActionController::API
  require 'rest-client'
  require 'json'
  before_action :api_access_token

  # wenn jemand in babili etwas verändert, löst er mit seinen access_tokens updates in den apps aus
  def create
    if api_access_token
      @data = api_access_token.get("/api/projects").parsed
      @projects = @data.select{|p| p['accessibilities'].map{|a| a['oauth_uid']}.include?(Rails.application.secrets.client_id) }
      
      if @projects
        app_projects = @projects.select{|p| p['accessibilities'].map{|a| a['oauth_uid']}.include?(Rails.application.secrets.client_id) }
        app_projects.each do |p_project|
          project = Project.where(babili_project_id: p_project['id'].to_i).first_or_create!
          project.update(
            babili_project_name: p_project['name'],
            published: p_project['data_published'],
            local_access: p_project['accessibilities'].select{|a| a['oauth_uid'] == Rails.application.secrets.client_id}.first['access'])
          p_project['memberships'].each do |member|
            user = User.where(uid: member['user_id'], provider: member['provider']).first_or_create!
            membership = project.memberships.where(user_id: user, project_id: project).first_or_create!
            membership.update(role: member['role'])
            project.update(owner_id: user.id) if member['role'] == 'Owner'
          end
        end
      end
    end
  end

  
private
  def oauth_client
    @oauth_client ||= OAuth2::Client.new(Rails.application.secrets.client_id, 
      Rails.application.secrets.client_secret, 
      site: Rails.application.secrets.provider_site)
  end

  def api_access_token
    @access_token ||= OAuth2::AccessToken.new(oauth_client, request.headers['Authorization'].split(' ').last) if request.headers['Authorization']
  end


end