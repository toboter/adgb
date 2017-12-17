class Api::V1::ArtefactsController < Api::V1::BaseController

  def index
    sort_order = Artefact.sorted_by(params[:sort].presence || 'updated_at_desc')
    artefacts = Artefact.visible_for(@user).order(sort_order)
    artefacts = artefacts.where("updated_at > ?", params[:since]) if params[:since]
    artefacts = artefacts.paginate(page: params[:page][:number], per_page: params[:page][:size] || 30)

    render json: artefacts, meta: pagination_dict(artefacts), each_serializer: ArtefactSerializer
  end

  def show
    artefact = Artefact.visible_for(@user).friendly.find(params[:id])
    render json: artefact, serializer: ArtefactSerializer
  end

  def search
    query = params[:q]
    sort_order = Artefact.sorted_by(params[:sort].presence || nil)
    artefact_ids = Artefact.visible_for(@user).all.ids
    results =
      Artefact.search(query,
        where: {id: artefact_ids},
        fields: [:_all],
        page: params[:page], 
        per_page: params[:per_page] || 30, 
        order: sort_order, 
        misspellings: false
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end
    render json: results, meta: pagination_dict(results), each_serializer: ArtefactSerializer
  end

end