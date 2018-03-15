class PhotoImportsController < ApplicationController
  require 'rest-client'
  require 'json'

  load_and_authorize_resource
  skip_load_resource only: :index
  skip_authorize_resource only: :index

  # GET /photos
  # GET /photos.json
  def index
    @photos = PhotoImport.visible_for(current_user).order(ph_rel: :asc)
    @photos = @photos.with_user_shared_to_like(params[:with_user_shared_to_like]) if params[:with_user_shared_to_like]
    @photos = @photos.with_unshared_records(params[:with_unshared_records]) if params[:with_unshared_records]
    @photos = @photos.with_published_records(params[:with_published_records]) if params[:with_published_records]
    @photos = @photos.paginate(:page => params[:page], per_page: session[:per_page])
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @commons = current_user ? current_user_repos.detect{|s| s.name == 'Commons'} : OpenStruct.new(url: "#{Rails.application.secrets.media_host}/api/commons/search", user_access_token: nil)
    @url = "#{@commons.collection_classes.first.repo_api_url}?q=#{@photo_import.name}&f=match}"
    begin
      response = RestClient.get(@url, {:Authorization => "Token #{@commons.user_access_token}"})
      @files= JSON.parse(response.body)
    rescue Errno::ECONNREFUSED
      "Server at #{@commons.url} is refusing connection."
      flash.now[:notice] = "Can't connect to #{@commons.url}."
      @files = []
    end

    # Artefact.visible_for(current_user).map{ |a| a.illustrations }  where.not?
    @occurences = @photo_import.occurences.where(artefact: Artefact.visible_for(current_user).all).order(position: :asc)
  end

  # GET /photos/new
  def new
    @photo_import = PhotoImport.new
  end

  # GET /photos/1/edit
  def edit
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo_import = PhotoImport.new(photo_import_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo_import, notice: 'Photo was successfully created.' }
        format.json { render :show, status: :created, location: @photo_import }
      else
        format.html { render :new }
        format.json { render json: @photo_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /photos/1
  # PATCH/PUT /photos/1.json
  def update
    respond_to do |format|
      if @photo_import.update(photo_import_params)
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { render :show, status: :ok, location: @photo_import }
      else
        format.html { render :edit }
        format.json { render json: @photo_import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo_import.destroy
    respond_to do |format|
      format.html { redirect_to photo_imports_url, notice: 'Photo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo_import = PhotoImport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_import_params
      params.require(:photo_import).permit(:ph_rel, :ph, :ph_nr, :ph_add, :ph_datum, :ph_text, occurences_attributes: [:id, :ph, :ph_nr, :ph_add, :position, :p_bab_rel, :_destroy])
    end
end
