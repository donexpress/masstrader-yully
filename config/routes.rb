Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  scope :v1, defaults: { format: :json } do
    resources :raw_events, only: [:index, :create] do
      post :ingest, on: :collection
      get :dump, on: :collection
    end

    resources :shipments, only: [:index]
  end
end
