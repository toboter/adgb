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
  end

end