Rails.application.routes.draw do
  # added by nabu
  concern :commentable do
    resources :comments, only: [:index, :new, :create, :destroy]
  end
  # 'concerns: :commentable' needs to be added to any resource where nabu is included.
  
  post "versions/:id/revert" => "versions#revert", :as => "revert_version"
  concern :versionable do
    resources :versions
    put :publish, on: :member
    put :unlock, on: :member
    resources :grants, except: [:index, :new, :edit] do
      get :candidates, to: 'grants#candidates', on: :collection
    end
  end

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
  
  resources :artefacts, concerns: [:commentable, :versionable], model_name: 'Artefact' do
    collection do
      get :mapview
      post :publish
      post :unlock
      post :grant_multiple, to: 'grants#grant_multiple'
      delete :revoke_multiple, to: 'grants#revoke_multiple'
    end
  end
  resources :artefact_people, only: :index, path: 'people', as: 'people'
  resources :artefact_references, only: :index, path: 'references', as: 'references'

  resources :sources, model_name: 'Source' do
    post :publish, on: :collection
    post :unlock, on: :collection
    post :grant_multiple, to: 'grants#grant_multiple', on: :collection
    delete :revoke_multiple, to: 'grants#revoke_multiple', on: :collection
  end
  resources :archives, controller: 'sources', type: 'Archive', model_name: 'Archive', concerns: [:commentable, :versionable]
  resources :collections, controller: 'sources', type: 'Collection', model_name: 'Collection', concerns: [:commentable, :versionable]
  resources :folders, controller: 'sources', type: 'Folder', model_name: 'Folder', concerns: [:commentable, :versionable]
  resources :letters, controller: 'sources', type: 'Letter', model_name: 'Letter', concerns: [:commentable, :versionable]
  resources :contracts, controller: 'sources', type: 'Contract', model_name: 'Contract', concerns: [:commentable, :versionable]
  resources :photos, controller: 'sources', type: 'Photo', model_name: 'Photo', concerns: [:commentable, :versionable]
  

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
