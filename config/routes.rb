Rails.application.routes.draw do
  root 'auth#login'
  
  # Authentication routes
  get 'login', to: 'auth#login'
  get 'register', to: 'auth#register'
  post 'login', to: 'auth#create_session'
  post 'register', to: 'auth#create_user'
  delete 'logout', to: 'auth#logout'
  
  # Project routes
  resources :projects, only: [:index, :show, :new, :create] do
    member do
      patch :update_status
    end
    resources :comments, only: [:create]
  end
end