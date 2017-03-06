class ArtefactPeopleController < ApplicationController
  load_and_authorize_resource
  
  def index
    @people = ArtefactPerson.paginate(:page => params[:page], :per_page => session[:per_page])
  end
end
