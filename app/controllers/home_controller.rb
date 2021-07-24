class HomeController < ApplicationController
  def index
    @tags = ActsAsTaggableOn::Tag.most_used
    @excavated_years = Artefact.order(gr_jahr: :asc).group(:gr_jahr).having(gr_jahr: 1899..1917).count
  end
end
