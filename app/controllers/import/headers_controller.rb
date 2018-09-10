module Import
  class HeadersController < ApplicationController
    before_action :authorize

    def update
      @event = Event.find(params[:event_id])
      @sheet = @event.sheets.find(params[:sheet_id])
      @header = @sheet.headers.find(params[:id])
      respond_to do |format|
        if @header.update(header_params)
          format.html { redirect_to [@event, @sheet], notice: "Header mapping was successfully saved." }
          format.js
        else
          format.html { render :show }
          format.js { render js: "toastr['error'](#{@header.errors.full_messages});", status: 422 }
        end
      end
    end

    private 

    def header_params
      params.require(:import_header).permit(
        :attribute_mapping,
      )
    end

  end
end