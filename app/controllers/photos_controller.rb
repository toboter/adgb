class PhotosController < ApplicationController
  require 'rest-client'
  require 'json'

  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  before_action :authorize, except: [:index, :show]
  load_and_authorize_resource

  # GET /photos
  # GET /photos.json
  def index
    @photos = Photo.paginate(:page => params[:page], :per_page => session[:per_page])
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @media = current_user_read_abilities.select{ |r| r['name'] == 'Media' }.first
    @url = "#{@media['url']}?q=#{@photo.name}&f=match}&access_token=#{@media['user_access_token']}"
    begin
      response = RestClient.get(@url)
      @photos = JSON.parse(response.body)
    rescue Errno::ECONNREFUSED
      "Server at #{@media['url']} is refusing connection."
      flash.now[:notice] = "Can't connect to #{@media['url']}."
      @photos = []
    end

    # Artefact.visible_for(current_user).map{ |a| a.illustrations }  where.not?
    @occurences = @photo.occurences.order(position: :asc)
  end

  # GET /photos/new
  def new
    @photo = Photo.new
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(photo_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        format.json { render :show, status: :created, location: @photo }
      else
        format.html { render :new }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { render :show, status: :ok, location: @photo }
      else
        format.html { render :edit }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url, notice: 'Photo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      params.require(:photo).permit(:ph_rel, :ph, :ph_nr, :ph_add, :ph_datum, :ph_text, occurences_attributes: [:id, :ph, :ph_nr, :ph_add, :position, :p_bab_rel, :_destroy])
    end
end
