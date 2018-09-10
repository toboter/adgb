module Import
  class EventsController < ApplicationController
    before_action :authorize
    
    def index
      @events = Event.all
    end

    def show
      @event = Event.find(params[:id])
    end

    def new
      @event = Event.new
    end

    def create
      @event = Event.new(event_params)

      respond_to do |format|
        if @event.save
          format.html { redirect_to @event, notice: "Import was successfully created." }
        else
          format.html { render :new }
        end
      end
    end


  

    def artefacts
      Artefact.import(params[:artefacts_file], params[:creator_id])
      redirect_to import_events_url, notice: "Artefacts table imported."
    end

    def artefacts_references
      ArtefactReference.destroy_all
      ArtefactReference.import(params[:artefacts_references_file])
      redirect_to import_events_url, notice: "ArtefactsReferences table imported."
    end

    def artefacts_photos
      ArtefactPhoto.delete_all
      ArtefactPhoto.import(params[:artefacts_photos_file])
      redirect_to import_events_url, notice: "ArtefactsPhotos table imported."
    end

    def artefacts_people
      ArtefactPerson.destroy_all
      ArtefactPerson.import(params[:artefacts_people_file])
      redirect_to import_events_url, notice: "ArtefactsPeople table imported."
    end

    def photos
      PhotoImport.import(params[:photos_file])
      redirect_to import_events_url, notice: "Photos table imported."
    end

    def transfer_photos
      Source.get_photos_from_photo_import(params[:transferer_id])
      Source.reset_source_on_artefact_reference
      redirect_to import_events_url, notice: "Photos table imported."
    end

    private
    def event_params
      params.require(:import_event).permit(
        :name, 
        :file, 
        :creator_id,
        sheets_attributes: {}
      )
    end
  end
end
