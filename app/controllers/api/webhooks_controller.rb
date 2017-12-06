class Api::WebhooksController < ActionController::API
  require 'rest-client'
  require 'json'

  before_action :set_token

  def sso_login

  end

  # application_url/api/hooks/update_accessibilities?access_token=babili-token
  def update_user_accessibilities
    user_url = "#{Rails.application.secrets.provider_site}/api/user"
    user_response = RestClient.get user_url, {:Authorization => "Bearer #{@token}"}
    user_parsed = JSON.parse(user_response.body)
    user = User.where(provider: 'babili', uid: user_parsed['id']).first

    # babili_accessibilities = JSON.parse(((current_user && access_token) ? access_token.get("/api/authorizations/clients/#{Rails.application.secrets.client_id}").body : []), object_class: OpenStruct)
    babili_access_url = "#{Rails.application.secrets.provider_site}/api/authorizations/clients/#{Rails.application.secrets.client_id}"
    babili_access_resp = RestClient.get babili_access_url, {:Authorization => "Bearer #{@token}"}
    babili_accessibilities = JSON.parse(babili_access_resp.body, object_class: OpenStruct)

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

    if user.save
      render json: {message: 'updated', status: 200}, status: :ok
    else
      render json: {message: 'failed', status: 400}, status: :bad_request
    end

    # raise user.inspect
    # erwartet oauth access token für babili
    # fragt nach user.accessibilities mit access token
  end
  
  private
  def set_token
    @token = request.headers['Authorization'] ? request.headers['Authorization'].split(' ').last : params[:access_token]
  end

end