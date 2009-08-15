ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  include AuthenticatedTestHelper

  # Sites

  def valid_options_for_site
    valid_acct = commenters(:quentin)
    { :account => valid_acct, :url => "http://google.com" }
  end

  def invalid_options_for_site
    valid = valid_options_for_site
    valid[:url] = nil
    valid # now invalid
  end

  def create_site(options = {})
    Site.create(valid_options_for_site.merge(options))
  end
  
  # Pages
  
  def valid_options_for_page_site
    valid_site = sites(:msn)
    { :url => valid_site.url + "/index.html", :site => valid_site }
  end
  
  # :url must be nil, PageController supplies account from session state
  def invalid_options_for_page
    valid = valid_options_for_page_site
    valid[:url] = nil
    valid
  end
  
  def create_page(options = {})
    Page.create(valid_options_for_page_site.merge(options))
  end

  # Commenters

  def valid_options_for_commenters
    { :email => "abc@abc.com" }
  end

  def invalid_options_for_commenters
    { :email => "foo" }
  end

  def create_commenter(options = {})
    Commenter.create(valid_options_for_commenters.merge(options))
  end

  # Accounts
  
  def valid_options_for_account
    commenter = commenters(:one)
    {:email => 'quire@example.com', :password => 'quire69', :name => 'Quentin' }
  end
  
  def invalid_options_for_account
    valid = valid_options_for_account
    valid.shift # makes valid invalid
    valid # now valid
  end
  
  def create_account(options = {})
    record = Account.new(valid_options_for_account.merge(options))
    record.save
    record
  end
  
  # Feedback / Comments
  
  def valid_options_for_comment
    page = pages(:msn)
    page.invites << invites(:one)
    commenter = commenters(:one)
    { :content=>'Hello, this is a feedback!', :page_id => page.id, :commenter_id => commenter.id, :target => 'html' }
  end
  
  def create_comment(options={})
    Comment.create(valid_options_for_comment.merge(options))
  end
  
  def invalid_options_for_comment
    valid_options_for_comment.merge({:content => nil})
  end
  
  
  # Invites
  
  def valid_options_for_invite
    { :commenter => commenters(:one), :page => pages(:msn) }
  end
  
  def create_invite(options={})
    Invite.create(valid_options_for_invite.merge(options))
  end
  
  # Opinions
  
  def valid_options_for_opinion
    { :feedback => feedbacks(:one), :commenter => commenters(:one), :agreed => true }
  end
  
  def create_opinion(options={})
    Opinion.create(valid_options_for_opinion.merge(options))
  end
  
  # User Style
  
  def valid_options_for_user_style
    page = pages(:msn)
    commenter = commenters(:one)
    { :page_id => page.id, :commenter_id => commenter.id, :changeset => {}.to_json }
  end
  
  def create_user_style(options={})
    UserStyle.create(valid_options_for_user_style.merge(options))
  end

  # Notification

  def valid_options_for_notification
    site = sites(:facebook)
    { :site => site }
  end

  def create_notification(options={})
    Notification.create(valid_options_for_notification.merge(options))
  end
  
  
  ### ACTUAL TEST HELPER METHODS ####
  def validate_json(args)
    callback = args.delete(:callback)
    
    # make sure the response is wrapped in the callback
    assert @response.body.match("^#{callback}\\(\\{"), "Expecting callback #{callback} but it wasn't found!"
    
    # get at just the JSON data (i.e. strip the JS callback wrapping it)
    json = @response.body.sub("#{callback}(", '').sub(/\);?/, '')
    validate_json_vals(json, args)
  end

  def get_json(callback)
    # make sure the response is wrapped in the callback
    assert @response.body.match("^#{callback}\\(\\{"), "Expecting callback #{callback} but it wasn't found!"
    
    # get at just the JSON data (i.e. strip the JS callback wrapping it)
    json = @response.body.sub("#{callback}(", '').sub(/\);?/, '')
    JSON.parse(json)
  end
  
  def validate_post_fail
    json_string = @response.body.match(/.*window.name='(.+)'/)[1]
    obj = JSON.parse(json_string)
    assert obj["success"] == false, "Should return JSON with success:false if post fails. Instead got: #{obj.inspect}"
  end
  
  # no callback when using windowname
  def validate_windowname(args)
     json_string = @response.body.match(/.*window.name='(.+)'/)[1]
     validate_json_vals(json_string, args)
  end
  
  def validate_json_vals(json_string, intended)
    # e.g. assert json['authorized'] == true
    json = JSON.parse(json_string)
    intended.each do |field_name, field_value|
      assert json[field_name.to_s] == field_value, "#{field_name} is set to #{json[field_name.to_s].inspect} instead of #{field_value.inspect}"
    end
  end
  
  # from: http://www.quackit.com/javascript/javascript_reserved_words.cfm
  def js_keywords
    %w(
    break continue do for import new this void
    case default else function in return typeof while
    comment delete export if label switch var with
    abstract implements protected
    boolean instanceOf public
    byte int short
    char interface static
    double long synchronized
    false native throws
    final null transient
    float package true
    goto private
    catch enum throw
    class extends try
    const finally
    debugger super
    alert eval Link outerHeight scrollTo
    Anchor FileUpload location outerWidth Select
    Area find Location Packages self
    arguments focus locationbar pageXoffset setInterval
    Array Form Math pageYoffset setTimeout
    assign Frame menubar parent status
    blur frames MimeType parseFloat statusbar
    Boolean Function moveBy parseInt stop
    Button getClass moveTo Password String
    callee Hidden name personalbar Submit
    caller history NaN Plugin sun
    captureEvents History navigate print taint
    Checkbox home navigator prompt Text
    clearInterval Image Navigator prototype Textarea
    clearTimeout Infinity netscape Radio toolbar
    close innerHeight Number ref top
    closed innerWidth Object RegExp toString
    confirm isFinite onBlur releaseEvents unescape
    constructor isNan  onError Reset untaint
    Date java onFocus resizeBy unwatch
    defaultStatus JavaArray onLoad resizeTo valueOf
    document JavaClass onUnload routeEvent watch
    Document JavaObject open scroll window
    Element JavaPackage opener scrollbars Window
    escape length Option scrollBy
    )
  end
  
end
