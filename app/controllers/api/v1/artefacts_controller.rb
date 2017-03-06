class Api::V1::ArtefactsController < ActionController::API
  require 'rest-client'
  require 'json'

  before_action :set_user

  def index
    render json: Artefact.visible_for(@user)
  end

  def show
    render json: Artefact.visible_for(@user).find(params[:id]), serializer: ArtefactSerializer
  end

  def search
    render json: Artefact.visible_for(@user).search(params[:q]), each_serializer: ArtefactSerializer
  end

  
private
  def set_user
    token = request.headers['Authorization'] ? request.headers['Authorization'].split(' ').last : params[:access_token]
    @user = User.find_by_token(token)
    # url = "#{Rails.application.secrets.provider_site}/api/projects"
    # response = RestClient.get(url,  {:Authorization => "Token #{token}"})
    # @project_ids = JSON.parse(response).select{|p| p['accessibilities'].map{|a| a['oauth_uid']}.include?(Rails.application.secrets.client_id) }.map{ |p| p['id']}
  end

end