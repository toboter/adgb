Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/signout', to: 'sessions#destroy', as: 'signout'
  put '/set_per_page', to: 'sessions#set_per_page'
  
  resources :imports, only: :index, path: 'import' do
    collection do
      post 'artefacts'
      post 'artefacts_people'
      post 'artefacts_references'
      post 'artefacts_photos'
      post 'photos'
    end
  end

  resources :photos
  resources :artefacts
  resources :artefact_people, only: :index, path: 'people', as: 'people'
  resources :artefact_references, only: :index, path: 'references', as: 'references'
  
  namespace :api, defaults: {format: 'json'} do
    scope module: :v1 do
      resources :artefacts, only: [:index, :show] do
        collection do
          get 'search'
        end 
      end  
    end
  end
  
  get '/api', to: 'home#api'
  get '/help', to: 'home#help'

  root 'home#index' 
end
