ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # widget
  map.widget '/widget', :controller => 'widget/source', :action => 'index'
  map.feedback_for_page '/feedback_for_page.js', :controller => 'widget/feedbacks', :action => 'feedback_for_page', :conditions => { :method => :get }
  map.new_feedback_for_page '/feedback_for_page.js', :controller => 'widget/feedbacks', :action => 'new_feedback_for_page', :conditions => { :method => :post }
  map.feedback_for_page_test '/post_feedback_for_page', :controller => 'widget/feedbacks', :action => 'new_feedback_for_page', :conditions => { :method => :post }
  map.opinion_on_feedback '/opinion_on_feedback', :controller => 'widget/opinions', :action => 'opinion', :conditions => { :method => :post }
  map.namespace :widget do |widget|
#    widget.resources :tags
    widget.tag_for_page 'pages/:page_id/feedbacks/:id/tag', :controller => 'tags', :action => "create", :conditions => { :method => :post }
    widget.tag_for_page 'pages/:page_id/feedbacks/:id/tag', :controller => 'tags', :action => "delete", :conditions => { :method => :delete }
  end

  # coreapp
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'accounts', :action => 'create'
  map.signup '/signup', :controller => 'accounts', :action => 'new'

  map.resources :accounts
  map.resource :session
  map.resources :sites

  # admin panel
  map.resources :pages do |page|
    # member /pages/1/feedbacks/1/something -- i.e. a specific feedback
    # collection /pages/1/feedbacks/something -- i.e. all the feedbacks
    page.resources :feedbacks, :member => { :add_tag => :post, :delete_tag => :delete }
    page.resources :commenters
  end
  
  map.feedback_for_page '/feedback_for_page.js', :controller => 'feedbacks', :action => 'feedback_for_page', :conditions => { :method => :get }
  map.new_feedback_for_page '/feedback_for_page.js', :controller => 'feedbacks', :action => 'new_feedback_for_page', :conditions => { :method => :post }
  map.feedback_for_page_test '/post_feedback_for_page', :controller => 'feedbacks', :action => 'new_feedback_for_page', :conditions => { :method => :post }
  map.opinion_on_feedback '/opinion_on_feedback', :controller => 'feedbacks', :action => 'opinion', :conditions => { :method => :post }

  map.dashboard 'accounts/:id/dashboard', :controller => "accounts", :action => 'dashboard'
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
  map.root :controller => "home", :action => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
   map.connect ':controller/:action/:id'
   map.connect ':controller/:action/:id.:format'
end
