class ArtefactReferencesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @references = ArtefactReference.paginate(:page => params[:page], :per_page => session[:per_page])
  end
end
