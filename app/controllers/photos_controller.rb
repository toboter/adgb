class PhotosController < ApplicationController
  require 'rest-client'
  require 'json'
  load_and_authorize_resource
  
  def show
    aph = "#{@photo.serie}#{@photo.number}"
    @ref = ArtefactReference.where(ph_rel: aph)
    @commons = current_user ? current_user_repos.detect{|s| s.name == 'Commons'} : OpenStruct.new(url: "#{Rails.application.secrets.media_host}/api/commons/search", user_access_token: nil)
    @url = "#{@commons.url}?q=#{@photo.name}&f=match}"
    begin
      response = RestClient.get(@url, {:Authorization => "Token #{@commons.user_access_token}"})
      @files= JSON.parse(response.body)
    rescue Errno::ECONNREFUSED
      "Server at #{@commons.url} is refusing connection."
      flash.now[:notice] = "Can't connect to #{@commons.url}."
      @files = []
    end

    # Artefact.visible_for(current_user).map{ |a| a.illustrations }  where.not?
    @occurences = @photo.occurences.where(artefact: Artefact.visible_for(current_user).all).order(position: :asc)
  end

end