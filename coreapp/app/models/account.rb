require 'digest/sha1'

class Account < Commenter
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :sites, :dependent => :destroy, :validate => false
  has_many :pages, :through => :sites
  
  belongs_to :commenter

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  after_create :deliver_welcome_email

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible  :email, :name, :password, :password_confirmation, :type,
    :preferred_notification_delivery

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_by_email(email.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end


  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def your_site?(url_to_test)
    mine = false
    urls = sites.map(&:url)
    
    begin
      # strip down to domain (e.g. www.example.com)
      urls.map! { |url| URI.parse(url).host }
      host_to_test = URI.parse(url_to_test).host
      
      urls.each do |url|
        # strip out www.
        www = /^www\./i
        url.sub! www, ''
        host_to_test.sub! www, ''
        
        mine = true if url.match /^#{host_to_test}$/i
      end
    rescue URI::InvalidURIError
    end    
    
    return mine
  end
  


  protected
    
  def deliver_welcome_email
    Mailer.deliver_account_signup(self)
    true
  end

end
