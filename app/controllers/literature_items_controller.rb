class LiteratureItemsController < ApplicationController
  load_and_authorize_resource

  def index
    @literature_items = @literature_items.order(jahr: :asc).paginate(:page => params[:page], :per_page => session[:per_page]).includes(:artefacts, :sources)
  end

  def show
  end

  def new
    redirect_to literature_items_url, notice: "Not implemented."
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

  def single_update_biblio_data
    item = Wrapper::Biblio.find(@literature_item.biblio_data['url'], access_token)
    respond_to do |format|
      if @literature_item.update(biblio_data: item)
        format.html { redirect_to @literature_item, notice: "Literature was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  def update_biblio_data
    items=[]
    LiteratureItem.where.not(biblio_data: {}).each do |i|
      if i.biblio_data['url'].present?
        item = Wrapper::Biblio.find(i.biblio_data['url'], access_token)
        items << i.update(biblio_data: item)
      end
    end if current_user.is_admin?
    redirect_to settings_users_path, notice: "#{view_context.pluralize(items.size, 'item')} successfuly updated from babylon-online.org/bibliography"
  end

  def destroy
    if @literature_item.artefacts.empty? && @literature_item.sources.empty?
      @literature_item.destroy
      redirect_to literature_items_url, notice: "Literature was successfully removed."
    else
      redirect_to @literature_item, notice: "There are associated objects."
    end
  end

  private
  def literature_item_params
    params.require(:literature_item).permit(:ver, :publ, :jahr, :biblio_data)
  end
end