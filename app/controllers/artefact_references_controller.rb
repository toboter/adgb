class ArtefactReferencesController < ApplicationController
  load_and_authorize_resource
  
  def index
    pre = ArtefactReference.where(artefact: Artefact.visible_for(current_user).all).order(ver: :asc, jahr: :asc, publ: :asc)
    pre = pre.where(ver: params[:ver], jahr: params[:jahr], publ: params[:publ]) if params[:ver] || params[:jahr] || params[:publ]
    @distinct = pre.group_by{|r| [r.ver, r.jahr, r.publ]}
    @references = pre.paginate(:page => params[:page], :per_page => session[:per_page]).includes(:artefact)
  end
end
