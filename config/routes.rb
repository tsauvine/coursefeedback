ActionController::Routing::Routes.draw do |map|
  map.resource :session
  map.resources :users
  
  map.resources :courses
  map.resources :course_instances
  map.resources :topics, :member => ['vote','moderate']
  map.resources :messages, :member => ['vote', 'moderate']
  map.resources :faq_entries, :controller => 'faq', :member => ['vote']
  
  map.resources :surveys, :member => ['answer','results'], :path_prefix => ':course_code/:instance_path', :requirements => { :course_code => URL_FORMAT_ROUTE, :instance_path => URL_FORMAT_ROUTE }
  map.resources :survey_questions, :member => ['move']
  map.resources :survey_answers
  
  #map.resources :courses, :requirements => { :id => /([a-zA-Z0-9\-+*_.,!$'()])*/ } do |courses|
  map.resources :courses do |courses|
    #course.resources :topics #, :requirements => { :topic_id => /[0-9]*/ }
    #course.resources :course_instances
    courses.resources :courseroles
  end 

  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.topic_index ':course/:instance/feedback', :controller => 'topics', :action => 'index', :requirements => { :course => URL_FORMAT_ROUTE, :instance => URL_FORMAT_ROUTE }
  map.new_topic ':course/:instance/new_topic', :controller => 'topics', :action => 'new', :requirements => { :course => URL_FORMAT_ROUTE, :instance => URL_FORMAT_ROUTE }
  
  map.faq ':course_code/:instance_path/faq', :controller => 'faq', :action => 'index', :requirements => { :course_code => URL_FORMAT_ROUTE, :instance_path => URL_FORMAT_ROUTE }
  map.new_faq ':course_code/:instance_path/new_faq', :controller => 'faq', :action => 'new', :requirements => { :course_code => URL_FORMAT_ROUTE, :instance_path => URL_FORMAT_ROUTE }

  map.instance_root ':course/:instance', :controller => 'topics', :action => 'index', :requirements => { :course => URL_FORMAT_ROUTE, :instance => URL_FORMAT_ROUTE }
  map.course_root ':course_code', :controller => 'courses', :action => 'show', :requirements => { :course_code => URL_FORMAT_ROUTE }


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  
  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'course_instances', :action => 'index'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
