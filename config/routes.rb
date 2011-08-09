CentralTodo::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  match 'sign_in' => 'user_sessions#new'
  match 'sign_out' => 'user_sessions#destroy'
  resource :user_session
  resources :users do
    collection do
      get 'multiple'
    end
    member do
      get 'activate'
      post 'request_password_reset'
      get 'forgot_password'
      get 'settings'
      get 'account'
      get 'show_full'
      get 'tos_agreement'
    end
  end
  match 'sign_up' => 'users#new'
  match 'my_account' => 'users#show'

  resources :plans, :controller => 'projects' do
    collection do
      get 'sort'
      get 'archived'
      get 'shared'
      get 'multiple'
      get 'archive_completed'
    end
    member do
      get 'archive_completed_tasks'
      get 'sort_tasks'
      get 'comments'
      get 'templatize'
      get 'show_full'
    end
  end
  resources :project_sharers
  resources :labels do
    collection do
      get 'multiple'
    end
    member do
      get 'archive_completed_tasks'
      get 'show_full'
    end
  end
  
  resources :tasks do
    collection do
      get 'priority'
      get 'unorganized'
      get 'due_date'
      get 'archive_completed'
      get 'archived_unorganized'
      get 'multiple'
      get 'multiple_comments'
    end
    member do
      get 'convert'
      get 'comments'
      get 'show_full'
    end
  end
  resources :comments do
    collection do
      get 'recent'
    end
  end
  resources :reminders
  resources :heads_ups
  resources :folders do
    collection do
      get 'sort'
      get 'multiple'
      get 'archived'
    end
    member do
      get 'sort_plans'
      get 'show_full'
    end
  end
  resources :plan_templates
  match 'page/:name' => 'pages#show'
  match 'dashboard' => 'dashboard#index'
  match 'dashboard/completed' => 'dashboard#completed'
  match 'dashboard/unorganized' => 'dashboard#unorganized'
  match 'schedule' => 'schedule#index'
  match 'terms' => 'pages#show', :name => 'Terms of Service', :as => :terms
  match 'privacy' => 'pages#show', :name => 'Privacy Policy', :as => :privacy
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  root :to => "pages#show", :name => 'Home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
