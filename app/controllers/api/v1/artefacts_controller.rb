class Api::V1::ArtefactsController < ActionController::API
  require 'rest-client'
  require 'json'

  before_action :set_user

  def index
    artefacts = Artefact.visible_for(@user).paginate(page: params[:page], per_page: 30)
    render json: artefacts, each_serializer: ArtefactSerializer
  end

  def show
    artefact = Artefact.visible_for(@user).friendly.find(params[:id])
    render json: artefact, serializer: ArtefactSerializer
  end

  def search
    artefact_ids = Artefact.visible_for(@user).all.ids
    results = Artefact.search(params[:q], 
      where: {id: artefact_ids},
      page: params[:page], 
      per_page: 30)
    render json: results, each_serializer: ArtefactSerializer
  end

  
private
  def set_user
    token = request.headers['Authorization'] ? request.headers['Authorization'].split(' ').last : params[:access_token]
    @user = User.find_by_token(token)
  end

end