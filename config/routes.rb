Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    namespace :v1 do
      # Users routes
      resources :users do
        member do
          post :follow
          delete :unfollow, action: :unfollow
          get :followers
          get :following
        end
        
        # Nested sleep records routes
        resources :sleep_records, except: [:create, :update] do
          collection do
            post :clock_in
            post :clock_out
            get :current
            get :friends
          end
        end
      end
      
      # Standalone follows routes
      resources :follows, only: [:index, :show, :create, :destroy]
    end
  end
end
