class Api::V1::SourcesController < ActionController::API
  require 'rest-client'
  require 'json'

  before_action :set_user

  def index
    render json: Source.visible_for(@user).all, each_serializer: SourceSerializer
  end

  def show
    render json: Source.visible_for(@user).friendly.find(params[:id]), serializer: SourceSerializer
  end
  
  def search
    @visible_sources_ids = Source.visible_for(@user).all.ids
    render json: Source.search(params[:q], where: {id: @visible_sources_ids}), each_serializer: SourceSerializer
  end

  private
  def set_user
    token = request.headers['Authorization'] ? request.headers['Authorization'].split(' ').last : params[:access_token]
    @user = token.present? ? User.find_by_token(token) : nil
  end
end