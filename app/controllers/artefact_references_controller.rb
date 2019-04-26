class ArtefactReferencesController < ApplicationController
  load_and_authorize_resource
  
  def index
    pre = ArtefactReference.where(artefact: Artefact.visible_for(current_user).all).order(ver: :asc, jahr: :asc, publ: :asc)
    pre = pre.where(ver: params[:ver], jahr: params[:jahr], publ: params[:publ]) if params[:ver] || params[:jahr] || params[:publ]
    @distinct = pre.group_by{|r| [r.ver, r.jahr, r.publ]}
    @references = pre.paginate(:page => params[:page], :per_page => session[:per_page]).includes(:artefact)
  end

  def normalize_to_literature_item
    items =[]
    items << ArtefactReference.all.map(&:sync_to_literature)
    redirect_to settings_users_path, notice: "#{items.flatten.size} entries normalized into literature."
  end

  def extract_to_literature_item_source
    items =[]
    items << ArtefactReference.where.not(source_id: nil).map(&:sync_between_literature_item_and_source)
    redirect_to imports_url, notice: "#{items.flatten.size} entries transfered and synced between sources and literature."
  end
end
