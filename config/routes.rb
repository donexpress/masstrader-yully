Rails.application.routes.draw do
  # Defines the root path route ("/")
  # root "articles#index"

  scope :v1, defaults: { format: :json } do
    resources :raw_events, only: [:index, :create] do
      post :ingest, on: :collection
      get :dump, on: :collection
    end

    resources :shipments, only: [:index]
  end

  scope :wa do
    resources :messages
    resources :conversations, except: [:destroy] do
      patch '/read', on: :member, action: :read
    end
    resources :fb_events, only: [:index]
  end

  get '/', to: 'health#index'
  get 'docs', to: 'docs#index'
  get 'fb-listener', to: 'fb_webhook#index'
  post 'fb-listener', to: 'fb_webhook#ingest'
end
