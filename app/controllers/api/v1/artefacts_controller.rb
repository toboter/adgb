class Api::V1::ArtefactsController < Api::V1::BaseController

  # /api/artefacts
  def index
    sort_order = Artefact.sorted_by(params[:sort].presence || 'updated_at_desc')
    artefacts = Artefact.visible_for(@user).order(sort_order)
    artefacts = artefacts.where("updated_at > ?", params[:since]) if params[:since]
    @artefacts = artefacts.paginate(page: params[:page], per_page: params[:per_page] || 30)
    @meta = pagination_dict(@artefacts)

    render template: "api/v1/artefacts/index"
  end

  def show
    @artefact = Artefact.visible_for(@user).friendly.find(params[:id])
    render template: "api/v1/artefacts/show"
  end

  # /api/artefacts/search
  def search
    query = params[:q].to_s.strip
    per_page = (params[:per_page] || 30).to_i
    page = params[:page]
    scope = Artefact.visible_for(@user)
    artefact_ids = scope.ids

    Rails.logger.info("[api/artefacts#search] user=#{@user&.id || 'anonymous'} visible=#{artefact_ids.size} q=#{query.inspect}")

    if query.blank? || artefact_ids.empty?
      @artefacts = scope.none.paginate(page: page, per_page: per_page)
      @meta = pagination_dict(@artefacts)
      return render template: "api/v1/artefacts/index"
    end

    sort_order = Artefact.sorted_by(params[:sort].presence || 'score_desc')
    begin
      @artefacts =
        Artefact.search(query,
          where: { id: artefact_ids },
          fields: [:default_fields],
          page: page,
          per_page: per_page,
          order: sort_order,
          misspellings: false
        ) do |body|
          body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
        end

      if Rails.env.development? && @artefacts.total_count.to_i.zero?
        Rails.logger.warn("[api/artefacts#search] OpenSearch returned 0 hits; using SQL fallback")
        @artefacts = sql_search_artefacts(scope, query, page, per_page)
      end
    rescue StandardError => e
      Rails.logger.warn("[api/artefacts#search] OpenSearch failed (#{e.class}: #{e.message}); using SQL fallback")
      @artefacts = sql_search_artefacts(scope, query, page, per_page)
    end

    @meta = pagination_dict(@artefacts)
    render template: "api/v1/artefacts/index"
  end

  private

  def sql_search_artefacts(scope, query, page, per_page)
    pattern = "%#{Artefact.sanitize_sql_like(query)}%"
    scope.where(
      "bab ILIKE :q OR bab_rel ILIKE :q OR f_obj ILIKE :q OR kod ILIKE :q OR grabung ILIKE :q OR mus_sig ILIKE :q OR mus_nr ILIKE :q OR standort ILIKE :q OR fo_text ILIKE :q",
      q: pattern
    ).order(updated_at: :desc).paginate(page: page, per_page: per_page)
  end
end

