class ArchivesController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    respond_to do |format|
      if @archive.save
        format.html { redirect_to sources_path(search: "archive:#{'"'+@archive.name+'"'}"), notice: "Archive was successfully created." }
      else
        format.html { render :new }
      end
    end
  end
 
  private
  def archive_params
    params.require(:archive).permit(:name)
  end

end