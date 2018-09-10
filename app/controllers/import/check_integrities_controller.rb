module Import
  class CheckIntegritiesController < ApplicationController

    def new
      @event = Event.find(params[:event_id])
      @sheet = @event.sheets.find(params[:sheet_id])
      @items = @sheet.load_import.as_json

    end

  end
end