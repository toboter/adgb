class ArtefactsController < ApplicationController
  require 'rest-client'
  require 'json'

  load_and_authorize_resource
  skip_load_resource only: [:index, :mapview, :publish, :unlock, :edit_multiple, :update_multiple]
  skip_authorize_resource only: [:index, :mapview, :publish, :unlock, :edit_multiple, :update_multiple]
  layout 'artefact', except: [:index, :mapview, :edit, :new, :edit_multiple, :update, :create]


  # GET /artefacts
  # GET /artefacts.json
  def index
    sort_order = Artefact.sorted_by(params[:sorted_by] ||= 'score_desc') if Artefact.any?
    query = params[:search].presence || '*'
    string_q = query.gsub('+', ' ').squish
    start_id = params[:start].presence || 1

    artefacts = Artefact
    .visible_for(current_user)
    .filter_by(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))

    per_page = params[:format] == 'json' && params[:all] == 'true' ? nil : session[:per_page]

    unless params[:all] == 'true' && params[:in_batches] == 'true' && current_user.id == 1
      @artefacts =
        Artefact.search(string_q,
          where: {id: artefacts.ids},
          fields: [:default_fields],
          page: params[:page],
          per_page: per_page,
          order: sort_order,
          misspellings: {below: 1}
        ) do |body|
          body[:query][:bool][:must] = { query_string: { query: string_q, default_operator: "AND" } }
          body[:track_total_hits] = true
        end
    end

    respond_to do |format|
      format.html
      format.js
      format.json {
        if params[:all] == 'true' && params[:in_batches] == 'true' && current_user.id == 1
          render json: artefacts.order('id ASC').paginate(page: params[:page], per_page: 10000), each_serializer: ArtefactSerializer
        else
          render json: @artefacts, each_serializer: ArtefactSerializer
        end
      }
    end
  end

  def mapview
    query = params[:search].presence || '*'
    string_q = query.gsub('+', ' ').squish

    artefacts = Artefact
      .visible_for(current_user)
      .filter_by(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))

    @artefacts =
      Artefact.search(string_q,
        where: {id: artefacts.ids},
        fields: [:default_fields],
        misspellings: {below: 1}
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: string_q, default_operator: "and" } }
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
    @contributions = Hash.new(0)
    @growth = Hash.new(0)
    @artefact.versions.each do |v|
      @contributions[User.find(v.whodunnit).name] += v.changed_characters_length if v.changed_characters_length.present?
      @growth[v.id] = v.total_characters_length if v.total_characters_length.present?
    end

    # This loads the text edition for the artefact on github which is an epidoc xml file and passes it to CETEIcean in the view
    repo = Rails.application.secrets.git_repo
    token = Rails.application.secrets.git_token
    if @artefact.mus_name.present?
      url = "https://api.github.com/search/code?q=repo:#{repo} filename:#{@artefact.mus_name.parameterize(separator: '_')}.xml"
      begin
        response = RestClient.get(url, {:Authorization => "Token #{token}", :Accept => "application/vnd.github.v3.raw"})
        search_data = JSON.parse(response.body)
        if search_data['total_count'].to_i >= 1
          path = search_data['items'][0]['path']
          file_url = "https://api.github.com/repos/#{repo}/contents/#{path}?token=#{token}"
          @html_url = search_data['items'][0]['html_url']
        else
          file_url = 'NotFound'
        end
      rescue RestClient::ExceptionWithResponse => e
        text_data = "<xml>#{e.response}</xml>"
      end
      if file_url != 'NotFound'
        begin
          response = RestClient.get(file_url, {:Authorization => "Token #{token}", :Accept => "application/vnd.github.v3.raw"})
          text_data = response.body
        rescue RestClient::ExceptionWithResponse => e
          text_data = "<xml>#{e.response}</xml>"
        end
      end
    end
    @text_data = text_data || '<xml>Keine Textbearbeitung gefunden!</xml>'

      #   begin
      #     response = RestClient.get(@url, {:Authorization => "Token #{@commons.user_access_token}"})
      #     @files= JSON.parse(response.body)
      #   rescue RestClient::ExceptionWithResponse => e
      #     e.response
      #   rescue Errno::ECONNREFUSED
      #     "Server at #{@commons.url} is refusing connection."
      #     flash.now[:notice] = "Can't connect to #{@commons.url}."
      #     @files = []
      #   end

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @artefact, serializer: ArtefactSerializer }
    end
  end

  # GET /artefacts/new
  def new
    @artefact = Artefact.new
  end

  # GET /artefacts/1/edit
  def edit
  end

  def edit_multiple
    @edit_artefacts = Artefact.visible_for(current_user).find(params[:artefact_ids]) if params[:artefact_ids]
    respond_to do |format|
      format.html
      format.js
    end
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

  def update_tags
    tags=[]
    @artefact.tags.each do |t|
      concept = Wrapper::Vocab.find(t.uuid, access_token)
      default_name = concept['prefLabel'].try('[]', 'de') || concept['prefLabel'].try('[]', 'en') || 'unknown language'
      default_url = concept['links']['html']
      tags << t.update(concept_data: concept, name: default_name, url: default_url)
    end
    redirect_to @artefact, notice: "#{view_context.pluralize(tags.size, 'tag')} successfuly updated from source"
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

  def update_multiple
    @artefacts = Artefact.visible_for(current_user).find(params[:artefact_ids])
    count = @artefacts.count
    add_tags = []
    artefact_params[:add_to_tag_list].reject(&:empty?).each do |concept|
      concept = concept.is_a?(String) ? JSON.parse(concept) : concept
      add_tags << ActsAsTaggableOn::Tag.where(uuid: concept['id']).first_or_create(name: concept['default_label'], url: concept['html_url'], concept_data: concept)
    end if artefact_params[:add_to_tag_list].is_a?(Array)
    remove_tags = []
    artefact_params[:remove_from_tag_list].reject(&:empty?).each do |concept|
      concept = concept.is_a?(String) ? JSON.parse(concept) : concept
      remove_tags << ActsAsTaggableOn::Tag.where(uuid: concept['id']).first_or_create(name: concept['default_label'], url: concept['html_url'], concept_data: concept)
    end if artefact_params[:remove_from_tag_list].is_a?(Array)
    @artefacts.reject! do |artefact|
      if can? :update, artefact
        artefact.tags << add_tags.map{|t| t unless t.in?(artefact.tags)}.compact
        artefact.tags.destroy(remove_tags.map{|t| t if t.in?(artefact.tags)}.compact)
        artefact.reindex
        true
      else
        false
      end
    end
    if @artefacts.empty?
      redirect_to artefacts_path, notice: "#{view_context.pluralize(count, 'Artefact')} successfully updated."
    else
      redirect_to artefacts_path, alert: "Something went wrong. Objects: #{@artefacts.inspect}"
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
        string_q = query.gsub('+', ' ').squish
        artefacts = Artefact
          .visible_for(current_user)
          .filter_by(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))

        sk_results = Artefact.search(string_q,
          where: { id: artefacts.ids },
          per_page: 10000,
          misspellings: {below: 1}
          ) do |body|
            body[:query][:bool][:must] = { query_string: { query: string_q, default_operator: "and" } }
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
        string_q = query.gsub('+', ' ').squish
        artefacts = Artefact
          .visible_for(current_user)
          .filter_by(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))

        sk_results = Artefact.search(string_q,
          where: { id: artefacts.ids },
          per_page: 10000,
          misspellings: {below: 1}
          ) do |body|
            body[:query][:bool][:must] = { query_string: { query: string_q, default_operator: "and" } }
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
      params.require(:artefact).permit(
        :locked,
        :bab_rel,
        :grabung, :bab, :bab_ind, :b_join, :b_korr,
        :mus_sig, :mus_nr, :mus_ind, :m_join, :m_korr,
        :kod, :grab, :text, :sig,
        :diss, :mus_id, :standort_alt, :standort,
        :mas1, :mas2, :mas3, :f_obj, :abklatsch, :zeichnung,
        :fo_tell, :fo1, :fo2, :fo3, :fo4, :fo_text,
        :utmx, :utmxx, :utmy, :utmyy,
        :inhalt, :period, :arkiv, :text_in_archiv, :jahr, :datum, :zeil2, :zeil1,
        :gr_datum, :gr_jahr, :creator_id,
        add_to_tag_list: [],
        remove_from_tag_list: [],
        tag_list: [],
        accessor_ids: [],
        references_attributes: [:id, :literature_item_id, :seite, :_destroy],
        illustrations_attributes: [:id, :ph, :ph_nr, :ph_add, :position, :p_rel, :source_id, :_destroy],
        people_attributes: [:id, :person, :titel, :_destroy]
      )
    end

end
