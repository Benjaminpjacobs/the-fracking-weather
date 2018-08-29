Rails.application.routes.draw do
  root "searches#index"
  resources :searches, only: [:index, :create, :show] do
    collection do
      get :previous_searches
    end
  end
end
