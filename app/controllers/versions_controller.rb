class VersionsController < ApplicationController
  before_action :set_parent, except: :revert

  def index
    @versions = @parent.versions
    @versions_by_month = @versions.order(created_at: :desc).group_by { |t| t.created_at.strftime('%d %m %Y') }

    instance_variable_set("@#{@parent.class.base_class.name.underscore}", @parent)
    render layout: @parent.class.base_class.name.underscore
  end

  def show
    @version = @parent.versions.find(params[:id]).reify
    @artefact = @version
    render 'artefacts/show'
  end

  def revert
    @version = PaperTrail::Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    link_name = params[:redo] == "true" ? "undo" : "redo"
    link = view_context.link_to(link_name, revert_version_path(@version.next, :redo => !params[:redo]), :method => :post)
    redirect_back fallback_location: root_path, notice: "Undid #{@version.event}. #{link}"
  end

  private

  def set_parent
    parent_class = params[:model_name].constantize
    parent_foreing_key = params[:model_name].foreign_key
  
    @parent = parent_class.friendly.find(params[parent_foreing_key])
  end

end