module Import
  class SheetsController < ApplicationController
    before_action :authorize

    def index
      @event = Event.find(params[:event_id])
      @sheets = @event.sheets
    end

    def show
      @event = Event.find(params[:event_id])
      @sheet = @event.sheets.find(params[:id])
    end

    def edit
      @event = Event.find(params[:event_id])
      @sheet = @event.sheets.find(params[:id])
      @model_types = %w[Artefact Source]
    end

    def update
      @event = Event.find(params[:event_id])
      @sheet = @event.sheets.find(params[:id])
      @model_types = %w[Artefact Source]
      respond_to do |format|
        if @sheet.update(sheet_params)
          format.html { redirect_to [@event, @sheet], notice: "Sheet mapping was successfully saved." }
          format.js
        else
          format.html { render :show }
          format.js { render js: "toastr['error'](#{@sheet.errors.full_messages});", status: 422 }
        end
      end
    end

    private 

    def sheet_params
      params.require(:import_sheet).permit(
        :model_mapping
      )
    end

  end
end