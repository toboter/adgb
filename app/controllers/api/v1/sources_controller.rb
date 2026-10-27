class Api::V1::SourcesController < Api::V1::BaseController

  def index
    sort_order = Source.sorted_by(params[:sort].presence || 'updated_at_desc')
    sources = Source.visible_for(@user).order(sort_order)
    sources = sources.where("updated_at > ?", params[:since]) if params[:since]
    @sources = sources.paginate(page: params[:page], per_page: params[:per_page] || 30)
    @meta = pagination_dict(@sources)

    render template: "api/v1/sources/index"
  end

  def show
    @source = Source.visible_for(@user).friendly.find(params[:id])
    render template: "api/v1/sources/show"
  end

  def search
    query = params[:q].to_s.strip
    per_page = (params[:per_page] || 30).to_i
    page = params[:page]
    scope = Source.visible_for(@user)
    source_ids = scope.ids

    Rails.logger.info("[api/sources#search] user=#{@user&.id || 'anonymous'} visible=#{source_ids.size} q=#{query.inspect}")

    if query.blank? || source_ids.empty?
      @sources = scope.none.paginate(page: page, per_page: per_page)
      @meta = pagination_dict(@sources)
      return render template: "api/v1/sources/index"
    end

    sort_order = Source.sorted_by(params[:sort].presence || 'score_desc')
    begin
      @sources = Source.search(query,
        where: { id: source_ids },
        fields: [:default_fields],
        page: page,
        per_page: per_page,
        order: sort_order,
        misspellings: false
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end

      if Rails.env.development? && @sources.total_count.to_i.zero?
        Rails.logger.warn("[api/sources#search] OpenSearch returned 0 hits; using SQL fallback")
        @sources = sql_search_sources(scope, query, page, per_page)
      end
    rescue StandardError => e
      Rails.logger.warn("[api/sources#search] OpenSearch failed (#{e.class}: #{e.message}); using SQL fallback")
      @sources = sql_search_sources(scope, query, page, per_page)
    end

    @meta = pagination_dict(@sources)
    render template: "api/v1/sources/index"
  end

  private

  def sql_search_sources(scope, query, page, per_page)
    pattern = "%#{Source.sanitize_sql_like(query)}%"
    scope.where(
      "call_number ILIKE :q OR temp_call_number ILIKE :q OR collection ILIKE :q OR title ILIKE :q OR keywords ILIKE :q OR remarks ILIKE :q",
      q: pattern
    ).order(updated_at: :desc).paginate(page: page, per_page: per_page)
  end
end

