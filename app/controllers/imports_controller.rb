class ImportsController < ApplicationController
  before_action :authorize
  
  def index
  end

  def artefacts
    Artefact.import(params[:artefacts_file], params[:creator_id])
    redirect_to imports_url, notice: "Artefacts table imported."
  end

  def artefacts_references
    ArtefactReference.destroy_all
    ArtefactReference.import(params[:artefacts_references_file])
    redirect_to imports_url, notice: "ArtefactsReferences table imported."
  end

  def artefacts_photos
    ArtefactPhoto.delete_all
    ArtefactPhoto.import(params[:artefacts_photos_file])
    redirect_to imports_url, notice: "ArtefactsPhotos table imported."
  end

  def artefacts_people
    ArtefactPerson.destroy_all
    ArtefactPerson.import(params[:artefacts_people_file])
    redirect_to imports_url, notice: "ArtefactsPeople table imported."
  end

  def photos
    PhotoImport.import(params[:photos_file])
    redirect_to imports_url, notice: "Photos table imported."
  end

  def transfer_photos
    Photo.get_photos_from_photo_import(params[:transferer_id])
    redirect_to imports_url, notice: "Photos table imported."
  end
end
