class SourcesController < ApplicationController
  before_action :set_type

  load_and_authorize_resource
  skip_load_resource only: [:index, :create]
  skip_authorize_resource only: :index

  # GET /sources
  # GET /sources.json
  def index
    sort_order = Source.sorted_by(params[:sorted_by].presence || nil ) if Source.any?
    query = params[:search].presence || '*'

    sources = Source
      .visible_for(current_user)
      .filter(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))

    @sources =
        type_class.search(query,
          where: {id: sources.ids},
          page: params[:page], 
          per_page: session[:per_page], 
          order: sort_order, 
          misspellings: {below: 1}
        ) do |body|
          body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
        end

    respond_to do |format|
      format.html
      format.json { render json: @sources, each_serializer: nil }
      format.js
    end
  end

  # GET /sources/1
  # GET /sources/1.json
  def show

    respond_to do |format|
      format.html
      format.json { render json: @source, serializer: SourceSerializer }
      format.js
    end
  end

  # GET /sources/new
  def new
    @source = type_class.new(parent_id: params[:parent_id])
  end

  # GET /sources/1/edit
  def edit
  end

  # POST /sources
  # POST /sources.json
  def create
    @source = type_class.new(source_params)

    respond_to do |format|
      if @source.save
        format.html { redirect_to @source, notice: "#{@type} was successfully created." }
        format.json { render :show, status: :created, location: @source }
      else
        format.html { render :new }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sources/1
  # PATCH/PUT /sources/1.json
  def update
    respond_to do |format|
      if @source.update(source_params)
        format.html { redirect_to @source, notice: "#{@type} was successfully updated." }
        format.json { render :show, status: :ok, location: @source }
      else
        format.html { render :edit }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.json
  def destroy
    @source.destroy
    respond_to do |format|
      format.html { redirect_to sources_url, notice: "#{@type} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_type 
      @type = type 
    end

    def type 
      Source.types.include?(params[:type]) ? params[:type] : "Source"
    end

    def type_class 
      type.constantize 
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_params
      params.require(type.underscore.to_sym).permit(
        :slug, 
        :identifier_stable, 
        :identifier_temp, 
        :type, 
        :remarks, 
        :parent_id, 
        type_class.jsonb_attributes)
    end
end
