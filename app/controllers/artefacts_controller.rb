class ArtefactsController < ApplicationController
  require 'rest-client'
  require 'json'

  load_and_authorize_resource
  skip_load_resource only: [:index, :mapview, :publish, :unlock]
  skip_authorize_resource only: [:index, :mapview, :publish, :unlock]
  layout 'artefact', except: [:index, :mapview, :edit, :new]


  # GET /artefacts
  # GET /artefacts.json
  def index
    sort_order = Artefact.sorted_by(params[:sorted_by] ||= 'score_desc') if Artefact.any?
    query = params[:search].presence || '*'
    
    artefacts = Artefact
    .visible_for(current_user)
    .filter(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))

    @artefacts =
      Artefact.search(query,
        where: {id: artefacts.ids},
        fields: [:default_fields],
        page: params[:page], 
        per_page: session[:per_page], 
        order: sort_order, 
        misspellings: {below: 1}
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def mapview
    query = params[:search].presence || '*'
    artefacts = Artefact
      .visible_for(current_user)
      .filter(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))
    
    @artefacts =
      Artefact.search(query,
        where: {id: artefacts.ids},
        fields: [:default_fields],
        misspellings: {below: 1}
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end

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
    @commons = current_user ? current_user_repos.detect{|s| s.name == 'Commons'} : OpenStruct.new(url: "#{Rails.application.secrets.media_host}/api/commons/search", user_access_token: nil)
    @illustrations_url = "#{@commons.collection_classes.first.repo_api_url}?q=#{@artefact.illustrations.map{|i| "'#{i.name}'"}.join(' OR ')}"
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
    
    @contributions = Hash.new(0)
    @growth = Hash.new(0)
    @artefact.versions.each do |v|
      @contributions[User.find(v.whodunnit).name] += v.changed_characters_length if v.changed_characters_length.present?
      @growth[v.id] = v.total_characters_length if v.total_characters_length.present?
    end
    @artefact_similar = @artefact.similar(fields: [:kod, :bab], where: {id: Artefact.visible_for(current_user).all.ids})

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

    respond_to do |format|
      if @artefact.save
        format.html { redirect_to @artefact, notice: "Artefact was successfully created." }
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
        format.html { redirect_to @artefact, notice: "Artefact was successfully updated. #{undo_link}" }
        format.json { render :show, status: :ok, location: @artefact }
      else
        format.html { render :edit }
        format.json { render json: @artefact.errors, status: :unprocessable_entity }
      end
    end
  end

  def publish
    respond_to do |format|
      if params[:id]
        @artefact = Artefact.friendly.find(params[:id])
        authorize! :publish, @artefact
        if !@artefact.locked? && @artefact.update(locked: true, paper_trail_event: 'publish')
          format.html { redirect_to @artefact, notice: "Artefact was successfully published. #{undo_link}" }
          format.json { render :show, status: :ok, location: artefact }
        else
          format.html { redirect_to @artefact, notice: "An error occured." }
          format.json { render json: @artefact.errors, status: :unprocessable_entity }
        end
      else
        authorize! :publish_multiple, Artefact
        query = params[:search].presence || '*'
        artefacts = Artefact
          .visible_for(current_user)
          .filter(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))
        
        sk_results = Artefact.search(query, 
          where: { id: artefacts.ids },
          per_page: 10000,
          misspellings: {below: 1}
          ) do |body|
            body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
          end
        
        results = Artefact.where(id: sk_results.map(&:id))
        
        @published_length = 0
        results.in_batches.each do |records|
          records_length = records.where(locked: false).each do |r|
            r.locked = true
            r.paper_trail_event = 'publish'
            r.save
          end
          # versions = records.map {|record| "(#{record.id},'#{record.class.base_class.name}','publish','#{current_user.id}',now(),now())" }
          # ActiveRecord::Base.connection.execute("INSERT INTO versions (item_id, item_type, event, whodunnit, created_at, updated_at) VALUES #{values.flatten.compact.to_a.join(",")}")
          @published_length = @published_length + records_length.count
        end
        if @published_length > 0
          format.html { redirect_to artefacts_path(search: params[:search]), notice: "Successfully published #{@published_length} artefacts." }
          format.json { render :index, status: :ok }
        else
          format.html { redirect_to artefacts_path(search: params[:search]), notice: "An error occured." }
          format.json { render :index, status: :unprocessable_entity }
        end
      end
    end
  end

  def unlock
    respond_to do |format|
      if params[:id]
        @artefact = Artefact.friendly.find(params[:id])
        authorize! :unlock, @artefact
        if @artefact.locked? && @artefact.update(locked: false, paper_trail_event: 'reopen')
          format.html { redirect_to @artefact, notice: "Artefact was successfully unlocked." }
          format.json { render :show, status: :ok, location: @artefact }
        else
          format.html { redirect_to @artefact, notice: "An error occured." }
          format.json { render json: @artefact.errors, status: :unprocessable_entity }
        end
      else
        authorize! :unlock_multiple, Artefact
        query = params[:search].presence || '*'
        artefacts = Artefact
          .visible_for(current_user)
          .filter(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))
        
        sk_results = Artefact.search(query, 
          where: { id: artefacts.ids },
          per_page: 10000,
          misspellings: {below: 1}
          ) do |body|
            body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
          end
        
        results = Artefact.where(id: sk_results.map(&:id))
        
        @unlocked_length = 0
        results.in_batches.each do |records|
          records_length = records.where(locked: true).each do |r|
            r.locked = false
            r.paper_trail_event = 'reopen'
            r.save
          end
          # versions = records.map {|record| "(#{record.id},'#{record.class.base_class.name}','publish','#{current_user.id}',now(),now())" }
          # ActiveRecord::Base.connection.execute("INSERT INTO versions (item_id, item_type, event, whodunnit, created_at, updated_at) VALUES #{values.flatten.compact.to_a.join(",")}")
          @unlocked_length = @unlocked_length + records_length.count
        end
        if @unlocked_length > 0
          format.html { redirect_to artefacts_path(search: params[:search]), notice: "Successfully reopened #{@unlocked_length} artefacts." }
          format.json { render :index, status: :ok }
        else
          format.html { redirect_to artefacts_path(search: params[:search]), notice: "An error occured." }
          format.json { render :index, status: :unprocessable_entity }
        end
      end
    end
  end
  
  # DELETE /artefacts/1
  # DELETE /artefacts/1.json
  def destroy
    @artefact.destroy
    respond_to do |format|
      format.html { redirect_to artefacts_url, notice: "Artefact was successfully removed. #{undo_link}" }
      format.json { head :no_content }
    end
  end

  private

    def undo_link
      view_context.link_to("undo", revert_version_path(@artefact.versions.last), method: :post)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def artefact_params
      params.require(:artefact).permit(:locked, :bab_rel, :grabung, :bab, :bab_ind, :b_join, :b_korr, :mus_sig, :mus_nr, :mus_ind, :m_join, :m_korr, :kod, :grab, :text, :sig, :diss, :mus_id, :standort_alt, :standort, :mas1, :mas2, :mas3, :f_obj, :abklatsch, :zeichnung, :fo_tell, :fo1, :fo2, :fo3, :fo4, :fo_text, :utmx, :utmxx, :utmy, :utmyy, :inhalt, :period, :arkiv, :text_in_archiv, :jahr, :datum, :zeil2, :zeil1, :gr_datum, :gr_jahr, :creator_id, accessor_ids: [], references_attributes: [:id, :ver, :publ, :jahr, :seite, :_destroy], illustrations_attributes: [:id, :ph, :ph_nr, :ph_add, :position, :p_rel, :_destroy], people_attributes: [:id, :person, :titel, :_destroy])
    end
    
end