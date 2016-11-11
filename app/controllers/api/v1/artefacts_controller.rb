class Api::V1::ArtefactsController < ActionController::API

  def index
    render json: Artefact.all, each_serializer: ArtefactSerializer
  end

  def show
    render json: Artefact.find(params[:id]), serializer: ArtefactSerializer
  end
  
  def search
    render json: Artefact.search(params[:q]), each_serializer: ArtefactSerializer
  end
end