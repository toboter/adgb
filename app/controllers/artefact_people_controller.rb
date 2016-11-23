class ArtefactPeopleController < ApplicationController
  def index
    @people = ArtefactPerson.paginate(:page => params[:page], :per_page => session[:per_page])
  end
end
