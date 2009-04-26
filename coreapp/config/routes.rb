ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  ### widget
  map.widget '/widget', :controller => 'widget/source', :action => 'index'
  map.feedback_for_page '/feedback_for_page.js', :controller => 'widget/feedbacks', :action => 'feedback_for_page', :conditions => { :method => :get }
  map.new_feedback_for_page '/feedback_for_page.js', :controller => 'widget/feedbacks', :action => 'new_feedback_for_page', :conditions => { :method => :post }
  map.feedback_for_page_test '/post_feedback_for_page', :controller => 'widget/feedbacks', :action => 'new_feedback_for_page', :conditions => { :method => :post }
  map.delete_feedback '/delete_feedback', :controller => 'widget/feedbacks', :action => 'destroy', :conditions => { :method => :delete }
  map.opinion_on_feedback '/opinion_on_feedback', :controller => 'widget/opinions', :action => 'opinion', :conditions => { :method => :post }
  map.namespace :widget do |widget|
    widget.tag_for_page 'pages/:page_id/feedbacks/:id/tag', :controller => 'tags', :action => "create", :conditions => { :method => :post }
    widget.tag_for_page 'pages/:page_id/feedbacks/:id/tag', :controller => 'tags', :action => "delete", :conditions => { :method => :delete }
  end

  ### coreapp
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'accounts', :action => 'create'
  map.signup '/signup', :controller => 'accounts', :action => 'new'

  map.resources :accounts, :member => { :dashboard => :get }
  map.resource :session
  map.resources :sites, :member => { :checkinclude => :put, :initial_invite_commenters => :put, :retrieveJS => :get }
  map.createsiteajax '/createsiteajax',    :controller => 'sites',           :action => 'create_ajax', :conditions => { :method => :post }
  #map.create_site_ajax '/opinion_on_feedback', :controller => 'widget/opinions', :action => 'opinion', :conditions => { :method => :post }
  
  ### admin panel
  map.namespace :admin_panel do |admin|
    # pages
    admin.site_pages '/:site_id/pages', :controller => 'pages', :action => 'index', :conditions => { :method => :get }
    admin.delete_site_page '/:site_id/pages/:id', :controller => 'pages', :action => 'destroy', :conditions => { :method => :delete }
    
    # commenters
    admin.commenters '/:site_id/commenters', :controller => 'commenters', :action => 'index', :conditions => { :method => :get }
    admin.invite '/:site_id/commenters', :controller => 'commenters', :action => 'create', :conditions => { :method => :post }
    admin.uninvite '/:site_id/commenters/:id', :controller => 'commenters', :action => 'destroy', :conditions => { :method => :delete }
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

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
   # map.connect ':controller/:action/:id'
   # map.connect ':controller/:action/:id.:format'
end
