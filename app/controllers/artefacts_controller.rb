class ArtefactsController < ApplicationController
  require 'rest-client'
  require 'json'

  load_and_authorize_resource
  skip_load_resource only: [:index, :mapview]
  skip_authorize_resource only: [:index, :mapview]


  # GET /artefacts
  # GET /artefacts.json
  def index
    sort_order = Artefact.sorted_by(params[:sorted_by].presence || 'bab_asc') if Artefact.any?
    query = params[:search]
    
    @artefact_ids = Artefact.visible_for(current_user).all.ids
    @artefacts = Artefact
      .search (query.presence || '*'), 
        where: {id: @artefact_ids},
        page: params[:page], 
        per_page: session[:per_page], 
        order: sort_order,
        aggs: [:type]
      
    respond_to do |format|
      format.html
      format.js
    end
  end

  def mapview
    query = params[:search]
    @artefact_ids = Artefact.visible_for(current_user).all.ids
    
    @artefacts = Artefact
      .search (query.presence || '*'), 
        where: {id: @artefact_ids},
        aggs: [:type]

    @gmhash = Gmaps4rails.build_markers(@artefacts) do |artefact, marker|
      if artefact.utm?
        marker.lat artefact.latitude
        marker.lng artefact.longitude
        marker.infowindow "#{artefact.full_entry} #{' ('+artefact.kod+')' if artefact.kod} #{', '+artefact.f_obj if artefact.f_obj}"
        # Die marker müssen noch abhängig von ihrer Genauigkeit eingefärbt werden. <= 10 ist rot, alles andere blau.
        marker.picture({
          :url => artefact.utmxx <= 10 && artefact.utmyy <= 10 ? "http://maps.google.com/mapfiles/ms/micons/red.png" : "http://maps.google.com/mapfiles/ms/micons/blue.png",
          :width   => 32,
          :height  => 32
        })
      end
    end
  end

  # GET /artefacts/1
  # GET /artefacts/1.json
  def show
    @commons = current_user ? current_user_search_abilities.detect{|s| s.name == 'Commons'} : OpenStruct.new(url: "#{Rails.application.secrets.media_host}/api/commons/search", user_access_token: nil)
    @illustrations_url = "#{@commons.url}?q=#{@artefact.illustrations.map{|i| "'#{i.name}'"}.join(' OR ')}"
    if @artefact.illustrations.any?
      begin
        response = RestClient.get(@illustrations_url, {:Authorization => "Token #{@commons.user_access_token}"})
        @files = JSON.parse(response.body)
      rescue Errno::ECONNREFUSED
        "Server at #{@commons.url} is refusing connection."
        flash.now[:notice] = "Can't connect to #{@commons.url}."
        @files = []
      end
    else 
      @files = []
    end
  end

  # GET /artefacts/new
  def new
    @artefact = Artefact.new
  end

  # GET /artefacts/1/edit
  def edit
  end

  # POST /artefacts
  # POST /artefacts.json
  def create
    @artefact = Artefact.new(artefact_params)
    @artefact.creator = current_user

    respond_to do |format|
      if @artefact.save
        format.html { redirect_to @artefact, notice: 'Artefact was successfully created.' }
        format.json { render :show, status: :created, location: @artefact }
      else
        format.html { render :new }
        format.json { render json: @artefact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /artefacts/1
  # PATCH/PUT /artefacts/1.json
  def update
    respond_to do |format|
      if @artefact.update(artefact_params)
        format.html { redirect_to @artefact, notice: 'Artefact was successfully updated.' }
        format.json { render :show, status: :ok, location: @artefact }
      else
        format.html { render :edit }
        format.json { render json: @artefact.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /artefacts/1
  # DELETE /artefacts/1.json
  def destroy
    @artefact.destroy
    respond_to do |format|
      format.html { redirect_to artefacts_url, notice: 'Artefact was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private

    def load_filterrific_set

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def artefact_params
      params.require(:artefact).permit(:filterrific, :bab_rel, :grabung, :bab, :bab_ind, :b_join, :b_korr, :mus_sig, :mus_nr, :mus_ind, :m_join, :m_korr, :kod, :grab, :text, :sig, :diss, :mus_id, :standort_alt, :standort, :mas1, :mas2, :mas3, :f_obj, :abklatsch, :abguss, :fo_tell, :fo1, :fo2, :fo3, :fo4, :fo_text, :utmx, :utmxx, :utmy, :utmyy, :inhalt, :period, :arkiv, :text_in_archiv, :jahr, :datum, :zeil2, :zeil1, :gr_datum, :gr_jahr, :creator_id, accessor_ids: [], references_attributes: [:id, :ver, :publ, :jahr, :seite, :_destroy], illustrations_attributes: [:id, :ph, :ph_nr, :ph_add, :position, :p_rel, :_destroy], people_attributes: [:id, :person, :titel, :_destroy])
    end
    
end