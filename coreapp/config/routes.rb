ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  ### widget
  map.namespace :widget do |widget|
    widget.resources :user_styles
    widget.resources :bookmarklet
  end
  map.widget '/widget/:id.js', :controller => 'widget/source', :action => 'index'
  map.widget '/widget/:id', :controller => 'widget/source', :action => 'index'
  map.feedback_for_page '/feedback_for_page.js', :controller => 'widget/feedbacks', :action => 'feedback_for_page', :conditions => { :method => :get }
  map.new_feedback_for_page '/feedback_for_page.js', :controller => 'widget/feedbacks', :action => 'new_feedback_for_page', :conditions => { :method => :post }
  map.feedback_for_page_test '/post_feedback_for_page', :controller => 'widget/feedbacks', :action => 'new_feedback_for_page', :conditions => { :method => :post }
  map.delete_feedback '/delete_feedback', :controller => 'widget/feedbacks', :action => 'destroy', :conditions => { :method => :post }
  map.opinion_on_feedback '/opinion_on_feedback', :controller => 'widget/opinions', :action => 'opinion', :conditions => { :method => :post }


  ### coreapp
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'accounts', :action => 'create'
  map.signup '/signup', :controller => 'accounts', :action => 'new'
  map.reset_password '/reset-password', :controller => 'accounts', :action => 'reset_password'
  map.about '/about', :controller => 'home', :action => 'about'
  map.contact '/contact', :controller => 'home', :action => 'contact'

  map.resources :accounts, :member => { :dashboard => :get, :reset_password => [:get, :put], :confirm_delete => :get }
  map.resource :session
  map.resources :sites, :member => { :embed => :get }
  
  
  ### admin panel
  map.namespace :admin_panel do |admin|
    # pages
    admin.site_pages '/:site_id/:validation_token/pages', :controller => 'pages', :action => 'index', :conditions => { :method => :get }
    admin.delete_site_page '/:site_id/:validation_token/pages/:id', :controller => 'pages', :action => 'destroy', :conditions => { :method => :delete }
    admin.search '/:site_id/:validation_token/search', :controller => 'pages', :action => 'search', :conditions => {:method => :post}
    
    # commenters
    admin.commenters '/:site_id/:validation_token/commenters', :controller => 'commenters', :action => 'index', :conditions => { :method => :get }
    admin.invite '/:site_id/:validation_token/commenters', :controller => 'commenters', :action => 'create', :conditions => { :method => :post }
    admin.uninvite '/:site_id/:validation_token/commenters/:id', :controller => 'commenters', :action => 'destroy', :conditions => { :method => :delete }
    admin.resend_invite '/:site_id/:validation_token/commenters/resend-invite/:id', :controller => 'commenters', :action => 'resend_invite', :conditions => { :method => :post }
  end
  
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

  # demo app routes for selenium testing
  map.connect 'demo/:action', :controller => "demo"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
   # map.connect ':controller/:action/:id'
   # map.connect ':controller/:action/:id.:format'
end
