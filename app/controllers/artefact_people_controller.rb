class ArtefactPeopleController < ApplicationController
  def index
    @people = ArtefactPerson.all
  end
end
