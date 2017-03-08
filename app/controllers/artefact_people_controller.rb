class ArtefactPeopleController < ApplicationController
  require 'will_paginate/array'
  load_and_authorize_resource
  
  def index
    @people = Artefact.visible_for(current_user).map{ |a| a.people }.flatten.paginate(:page => params[:page], :per_page => session[:per_page])
  end
end
