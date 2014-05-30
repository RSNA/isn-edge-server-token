Rails.application.routes.draw do


  # map.change_password '/change_password', :controller => 'users', :action => 'change_password'
  # map.connect '/users/roles', :controller => 'users', :action => 'roles'
  # map.connect '/users/set_role', :controller => 'users', :action => 'set_role'
  # map.connect '/users/set_status', :controller => 'users', :action => 'set_status'
  # map.connect '/users/change_password', :controller => 'users', :action => 'change_password'
  # map.connect '/users/reset_password', :controller => 'users', :action => 'reset_password'
  # map.connect '/users/reset_password_form', :controller => 'users', :action => 'reset_password_form'
  # map.resources :users
  # map.resource :session

  match 'users/change_password', to: "users#change_password", via: [:get]
  match 'users/roles', to: 'users#roles', via: [:get]
  resources :users, only: [:create, :reset_password, :set_role, :set_status], via: [:post]
  resource :session
  match ':controller(/:action(/:id))', via: [:get, :post]


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'exams#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
