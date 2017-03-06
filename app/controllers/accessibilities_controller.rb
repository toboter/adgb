class AccessibilitiesController < ApplicationController
  before_action :authorize

  def add_multiple_accessors
    rklass = params[:record_class].constantize
    @accessors = User.where(id: params[:accessor_ids])
    @records = rklass.where(id: params[:record_ids])
    @records.each do |record|
      record.accessors << @accessors.map{|a| a unless record.accessors.include?(a)}.compact
    end
    redirect_to url_for(rklass), notice: "Accessors successfully added to #{rklass.name.pluralize}."
  end

  def remove_multiple_accessors
    rklass = params[:record_class].constantize
    @accessors = User.where(id: params[:accessor_ids])
    @records = rklass.where(id: params[:record_ids])
    @records.each do |record|
      record.accessors.delete(@accessors)
    end
    redirect_to url_for(rklass), notice: 'Accessors successfully removed.'
  end

end
