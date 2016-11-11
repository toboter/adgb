class ArtefactReferencesController < ApplicationController
  def index
    @references = ArtefactReference.all
  end
end
