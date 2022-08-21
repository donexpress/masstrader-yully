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
  end

  get 'docs', to: 'docs#index'
  get 'fb-listener', to: 'fb_webhook#index'
  post 'fb-listener', to: 'fb_webhook#ingest'
end
