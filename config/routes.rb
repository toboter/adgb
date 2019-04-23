Rails.application.routes.draw do
 
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
      post 'transfer_photos'
      post 'literature_items_from'
      post 'literature_item_sources_from'
      post 'update_tag_concepts_from'
    end
  end
  
  resources :photo_imports
  
  resources :artefacts, concerns: [:versionable], model_name: 'Artefact' do
    collection do
      get :mapview
      post :edit_multiple
      put :update_multiple
      post :publish
      post :unlock
      post :grant_multiple, to: 'grants#grant_multiple'
      delete :revoke_multiple, to: 'grants#revoke_multiple'
    end
    member do
      put :update_tags
    end
  end
  resources :artefact_people, only: :index, path: 'people', as: 'people'
  resources :literature_items do
    collection do
      delete :remove_empty
    end
  end

  resources :sources, concerns: [:versionable], model_name: 'Source' do
    collection do
      post :edit_multiple
      put :update_multiple
      post :publish
      post :unlock
      post :grant_multiple, to: 'grants#grant_multiple'
      delete :revoke_multiple, to: 'grants#revoke_multiple'
    end
  end
  resources :archives, only: [:index, :new, :create]

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
  resources :concepts, only: :show do
    get :search, on: :collection
  end
  #get '/concepts/search', to: 'concepts#search'
  #get '/concepts/:id', to: 'concepts#search'
  get '/bibliography/search', to: 'biblio_wrapper#search'

  root 'home#index' 
end
