class ArtefactPeopleController < ApplicationController
  load_and_authorize_resource
  
  def index
    pre = ArtefactPerson.where(artefact: Artefact.visible_for(current_user).all).order(person: :asc)
    pre = pre.where(person: params[:person]) if params[:person]
    @distinct = pre.group_by(&:person)
    @people = pre.paginate(:page => params[:page], :per_page => session[:per_page]).includes(:artefact)
  end
end
