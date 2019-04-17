class LiteratureItemsController < ApplicationController
  load_and_authorize_resource

  def index
    @literature_items = @literature_items.order(jahr: :asc).paginate(:page => params[:page], :per_page => session[:per_page]).includes(:artefacts, :sources)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
    respond_to do |format|
      if @literature_item.update(literature_item_params)
        format.html { redirect_to @literature_item, notice: "Literature was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    if @literature_item.artefacts.empty? && @literature_item.sources.empty?
      @literature_item.destroy
      redirect_to literature_items_url, notice: "Literature was successfully removed."
    else
      redirect_to @literature_item, notice: "There are associated objects."
    end
  end

  def remove_empty
    @literature_items = LiteratureItem.left_outer_joins(:artefacts).where(artefacts: {id: nil})
    redirect_to literature_items_url, notice: "currently disabled."
    #size = @literature_items.destroy_all.size
    #redirect_to literature_items_url, notice: "#{size} removed."
  end

  private
  def literature_item_params
    params.require(:literature_item).permit(:ver, :publ, :jahr, :biblio_data)
  end
end