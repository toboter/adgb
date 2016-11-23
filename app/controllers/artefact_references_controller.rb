class ArtefactReferencesController < ApplicationController
  def index
    @references = ArtefactReference.paginate(:page => params[:page], :per_page => session[:per_page])
  end
end
