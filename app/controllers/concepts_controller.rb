class ConceptsController < ApplicationController

  def search
    render json: Wrapper::Vocab.search(params[:q], access_token).to_json
  end

  def show
    render json: Wrapper::Vocab.find(params[:id], access_token).to_json
  end

end