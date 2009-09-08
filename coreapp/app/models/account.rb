require 'digest/sha1'

class Account < Commenter
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :sites, :dependent => :destroy, :validate => false
  has_many :pages, :through => :sites
  
  belongs_to :commenter

  validates_presence_of     :name
  validates_presence_of     :plan_name
  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message
  validates_length_of       :name,     :maximum => 100
  validates_uniqueness_of   :email

  after_create :deliver_welcome_email

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible  :email, :name, :password, :type, :preferred_deliver_notifications, :job_title


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

  def find_site_by_url(url)
    sites.each do |site|
      if URI.same_domain?(site.url, url)
        return site
      end
    end
    nil
  end

  # generate a temporary password, and send it to the user
  def reset_password!
    new_password = `head -n 1 /dev/random | openssl base64`[0..12].chomp
    self.update_attribute(:password, new_password)
    Mailer.deliver_reset_password(self)
  end

  def free?
    plan_name == 'free'
  end

  def paid?
    !free?
  end

  def plan_price
    case plan_name
    when 'large'
      '99'
    when 'medium'
      '79'
    when 'small'
      '49'
    else
      '0'
    end
  end

  protected
    
  def deliver_welcome_email
    Mailer.deliver_account_signup(self)
    true
  end

end
