class Api::V1::SourcesController < ActionController::API
  require 'rest-client'
  require 'json'

  before_action :set_user

  def index
    sources = Source.visible_for(@user).paginate(page: params[:page], per_page: 30)
    render json: sources, each_serializer: SourceSerializer
  end

  def show
    source = Source.visible_for(@user).friendly.find(params[:id])
    render json: source, serializer: SourceSerializer
  end
  
  def search
    source_ids = Source.visible_for(@user).all.ids
    results = Source.search(params[:q], 
      where: {id: source_ids},
      page: params[:page], 
      per_page: 30)
    render json: results, each_serializer: SourceSerializer
  end

  private
  def set_user
    token = request.headers['Authorization'] ? request.headers['Authorization'].split(' ').last : params[:access_token]
    @user = token.present? ? User.find_by_token(token) : nil
  end
end