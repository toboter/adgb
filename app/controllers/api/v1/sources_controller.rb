class Api::V1::SourcesController < Api::V1::BaseController

  def index
    sort_order = Source.sorted_by(params[:sort].presence || 'updated_at_desc')
    sources = Source.visible_for(@user).order(sort_order)
    sources = sources.where("updated_at > ?", params[:since]) if params[:since]
    sources = sources.paginate(page: params[:page][:number], per_page: params[:page][:size] || 30)

    render json: sources, meta: pagination_dict(sources), each_serializer: SourceSerializer
  end

  def show
    source = Source.visible_for(@user).friendly.find(params[:id])
    render json: source, serializer: SourceSerializer
  end
  
  def search
    query = params[:q]
    sort_order = Source.sorted_by(params[:sort].presence || nil)
    source_ids = Source.visible_for(@user).all.ids
    results = Source.search(params[:q], 
      where: {id: source_ids},
      page: params[:page][:number], 
      per_page: params[:page][:size] || 30, 
      order: sort_order, 
      misspellings: false
    ) do |body|
      body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
    end
    render json: results, meta: pagination_dict(results), each_serializer: SourceSerializer

  end

end