Rails.application.routes.draw do
  # added by nabu
  concern :commentable do
    resources :comments, only: [:index, :new, :create, :destroy]
  end
  # 'concerns: :commentable' needs to be added to any resource where nabu is included.
  
  resources :imports, only: :index, path: 'import' do
    collection do
      post 'artefacts'
      post 'artefacts_people'
      post 'artefacts_references'
      post 'artefacts_photos'
      post 'photos'
    end
  end
  
  resources :photo_imports
  
  
  resources :artefacts, concerns: :commentable do
    collection do
      put :add_multiple_accessors
      delete :remove_multiple_accessors
      get :mapview
    end
  end
  resources :artefact_people, only: :index, path: 'people', as: 'people'
  resources :artefact_references, only: :index, path: 'references', as: 'references'
  resources :photos, concerns: :commentable, only: :show
  resources :sources
  resources :archives, controller: 'sources', type: 'Archive', concerns: :commentable
  resources :collections, controller: 'sources', type: 'Collection', concerns: :commentable
  resources :folders, controller: 'sources', type: 'Folder', concerns: :commentable
  resources :letters, controller: 'sources', type: 'Letter', concerns: :commentable
  resources :contracts, controller: 'sources', type: 'Contract', concerns: :commentable
  resources :photos, controller: 'sources', type: 'Photo', concerns: :commentable, except: :show
  
  namespace :api, defaults: {format: 'json'} do
    scope module: :v1 do
      resources :artefacts, only: [:index, :show] do
        get 'search', on: :collection 
      end
      resources :sources, only: [:index, :show] do
        get 'search', on: :collection
      end 
    end
    scope :hooks do
      get 'update_accessibilities', to: 'webhooks#update_user_accessibilities'
      get 'upload_local_user_token', to: 'webhooks#add_token_to_babili'
    end
  end

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/signout', to: 'sessions#destroy', as: 'signout'
  put '/set_per_page', to: 'sessions#set_per_page'
  # resources :users, except: :show, path: '/admin/users'

  resources :users, path: '/admin/users' do
    get 'add_token_to_babili', to: 'users#add_token_to_babili', on: :collection
    get 'get_accessibilities', to: 'users#update_accessibilities', on: :collection
    get 'settings', to: 'users#settings', on: :collection
  end
  
  get '/api', to: 'home#api'
  get '/search', to: 'search#index'

  root 'home#index' 
end
