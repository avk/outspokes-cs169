class Site < ActiveRecord::Base

  has_many :pages, :order => "pages.created_at ASC", :dependent => :destroy
  belongs_to :account

  attr_protected :validation_token, :validation_timestamp

  validates_presence_of :account_id
  validates_associated :account
  
  after_create :set_home_page!, :set_name!

  def initialize(*args, &block)
    super
    # If self.public is set before home_page is created, must remember to make home_page public
    @is_public = false
  end


  # url and home_page logic ####################################################################
  def url
    if (not home_page)
      @url
    else
      home_page.url
    end
  end

  def url=(url)
    if (home_page)
      raise Exception.new("Cannot set a URL for a site that already has a home_page: #{self}")
    else
      @url = url # used in the after_save :set_home_page! callback
    end
  end

  def home_page
    self.pages.first
  end

  def home_page=(page)
    if (home_page)
      errors.add_to_base("Cannot set the home page of a site")
    else
      self.pages << page
    end
  end


  # public sites logic #########################################################################
  def public
    # Rails keeps setting @is_public to nil. WTF?
    return home_page ? home_page.allow_public_comments : false | @is_public
  end

  def public=(pub)
    return if pub.nil?
    @is_public = pub
    pages.each { |page| page.allow_public_comments = pub }
  end

  def self.find_public_site_by_url(url)
    pub_pages = Page.find_all_by_allow_public_comments true
    current_site = nil
    longest_match = 0
    pub_pages.each do |page|
      if page.site.blank?
        next
      elsif url[0, page.url.length] == page.url && page.url.length > longest_match
        longest_match = page.url.length
        current_site = page.site
      end
    end
    return current_site
  end


  # validation token and timestamp logic ###############################################################
  def new_validation_token
    now = Time.now
    new_token = Digest::MD5::hexdigest(self.url + '1nkt0m^' + rand.to_s + now.to_s)
    self.validation_token = new_token
    self.validation_timestamp = now
    save
    self.validation_token
  end
  
  def verify_validation_token(token)
    if self.validation_token == token
      # token 'age' discourages session fixation attacks
      if self.validation_timestamp < 4.hours.ago
        new_validation_token
      else # not too old
        self.validation_token
      end
    else
      new_validation_token
      nil
    end
  end


  # misc logic ##########################################################################################
  def commenters
    home_page.commenters
  end

  def admin_url
    home_page.url.sub(/\/$/i, '') + '#url_token=' + home_page.invites.find_by_commenter_id(account).url_token + '&admin=true'
  end

  def pages_with_latest_feedback
    pages.find(:all,
    :select => "pages.id, url, MAX(f.created_at) AS latest_feedback", 
    :joins => "INNER JOIN feedbacks f ON f.page_id = pages.id", 
    :group => "pages.id",
    :order => "f.created_at DESC")
  end


  # callbacks ###########################################################################################

  def validate
    if self.url.nil?
      errors.add_to_base("URL can't be blank")
    else
      errors.add_to_base("URL is invalid") unless (self.url.match URI.regexp(['http', 'https']))
    end
  end
  
  def set_home_page!
    self.home_page = Page.new(:url => @url, :site => self, :allow_public_comments => @is_public)
  end

  def set_name!
    # agent = WWW::Mechanize.new
    # self.name = agent.get(self.home_page.url).title
    self.name = URI.parse(self.url).host
    self.save
  end

end
