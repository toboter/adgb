class BiblioWrapperController < ApplicationController

  def search
    render json: Wrapper::Biblio.search(params[:q], access_token).to_json
  end

end