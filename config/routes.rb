Rails.application.routes.draw do

  match 'users/change_password', to: "users#change_password", via: [:get,:post]
  match 'users/roles', to: 'users#roles', via: [:get,:post]
  resource :users, only: [:create, :reset_password, :set_role, :set_status], via: [:post,:get]
  get 'session', to: 'sessions#destroy'
  resource :session
  match ':controller(/:action(/:id))', via: [:get, :post], controller: /[^\/]+_configurations/, id: /[^\/]+/
  match ':controller(/:action(/:id))', via: [:get, :post]

  root 'patients#index'
end
