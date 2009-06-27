require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < ActiveSupport::TestCase
  
  test 'should create site' do
    assert_difference 'Site.count' do
      site = create_site(:url => "http://google.com")
      assert !site.new_record?, "#{site.errors.full_messages.to_sentence}"
      assert !site.home_page.nil?, "creating a site without a home page"
    end
  end

  test 'should require an account' do
    assert_no_difference "Site.count" do
      site = create_site(:url => "http://google.com", :account => nil)
      assert site.errors.on(:account)
    end
  end
  
  test 'should not be saved with an invalid account' do
    assert_no_difference "Site.count" do
      site = create_site(:url => "http://google.com", :account => Account.new(invalid_options_for_account))
      assert site.errors.on(:account)
    end
  end

  test 'should require a valid account' do
    assert_difference "Site.count", 1 do
      site = create_site(:url => "http://google.com", :account => create_account)
      assert !site.new_record?, "#{site.errors.full_messages.to_sentence}"
    end
  end

  test 'should always return pages they order they were created' do
    site = create_site(:url => "http://google.com")
    %w(/about /contact_us /FAQ).each do |page|
      site.pages << Page.new(:url => site.home_page.url + page)
    end
    ordered_pages = Page.find_by_sql "SELECT * FROM pages p WHERE p.site_id = #{site.id} ORDER BY created_at ASC"
    assert site.pages == ordered_pages
  end
  
  test 'should require at least one page' do
    url = "http://yahoo.com"
    site = create_site(:url => url)
    assert site.pages.size >= 1, "Site has at least one page"
    assert site.pages[0].url == url, "Site's home_page's url is its first page's url"
  end
  
  test 'should delete all pages when deleted' do
    base_url = "http://google.com"
    site = nil
    assert_difference "Site.count", 1 do
      site = create_site(:url => base_url)
    end
    
    page_urls = %w(/maps /movies /alerts)
    assert_difference "Page.count", page_urls.size do
      page_urls.each do |page_url|
        site.pages << Page.new(:url => "#{base_url + page_url}")
      end
      site.save
    end
    
    assert_difference "Site.count", -1 do
      assert_difference "Page.count", -(page_urls.size + 1) do # + 1 for the site's home page
        site.destroy
      end
    end
  end

  test 'should respond to home page' do
    url = "http://yahoo.com"
    site = create_site(:url => url)
    assert site.pages[0] == site.home_page
  end
  
  test "can't change a site's home_page once created" do 
    site = create_site(:url => "http://google.com")
    new_page = create_page
    site.reload
    site.home_page = new_page
    assert site.errors.on_base
    assert site.home_page != new_page
  end
  
  test 'should be able to get url via Site#url' do
    url = "http://google.com"
    site = create_site(:url => url)
    assert site.url == url
  end
  
  test 'changing site.url raises exception' do
    site = sites(:linkedin)
    url = site.url
    assert_raise Exception do
      site.url = "http://yahoo.com"
    end
    assert site.url == url
  end
  
  test "shouldn't be able to add a page to a site from a different url" do
    root_url = "http://google.com"
    new_url = "http://www.yahoo.com/r/i1"
    site = create_site(:url => root_url)
    assert_no_difference "site.pages.count" do
      page = Page.new(:url => new_url, :site => site)
      site.pages << page
    end
  end
  
  test "should be able to add valid pages to a site" do
    root_url = "http://google.com"
    new_url = "http://google.com/ig"
    site = create_site(:url => root_url)
    assert_difference "site.pages.count" do
      page = Page.new(:url => new_url, :site => site)
      site.pages << page
    end
  end
  
#  TODO: remove
#  test "should return correct public site" do 
#    site = Site.find_public_site_by_url "http://localhost:3001/asite/"
#    assert_equal sites(:public), site, "Found #{site} for http://localhost:3001/asite/"
#    site = Site.find_public_site_by_url "http://localhost:3001/asite/lol.html"
#    assert_equal sites(:public), site
#    site = Site.find_public_site_by_url "http://localhost:3001/anothersite/cats.html"
#    assert_equal sites(:alt_public), site
#  end

  def test_should_be_able_to_retrieve_a_sites_pages_with_the_latest_feedback_for_each_page
    site = create_site(:url => 'http://www.google.com')
    assert_difference "Page.count", 3 do
      3.times do |i|
        Page.create(:url => site.url + '/' + i.to_s, :site => site)
      end
    end
    
    timestamps = {}
    
    num_comments = 3
    assert_difference "Comment.count", (site.pages.size * num_comments) do
      site.pages.each do |p|
        num_comments.times do |i| 
          c = create_private_comment(:page_id => p.id, :content => i.to_s)
          timestamps[p.id] = c.created_at.to_s if i == num_comments - 1
        end
      end
    end
    
    got = site.pages_with_latest_feedback
    got.each do |page|
      expected = timestamps[page.id].split(" UTC")[0]
      assert page.latest_feedback == expected, "#{page.url}'s latest feedback #{page.latest_feedback} doesn't equal #{expected}"
    end
  end

  test "should be able to list it's commenters" do
    site = sites(:linkedin)
    assert site.commenters == site.home_page.commenters
  end
  
  def test_should_be_able_to_generate_a_validation_token_and_return_it
    site = sites(:linkedin)
    vtoken = site.new_validation_token
    site.reload
    assert !site.validation_token.blank?
    assert site.validation_token == vtoken
  end
  
  def test_should_not_reuse_validation_tokens
    site = Site.first
    tokens = []
    expected = 5
    expected.times { tokens << site.new_validation_token }
    got = tokens.uniq.size
    assert expected == got, "got #{got} instead of #{expected}"
  end
  
  def test_should_generate_randomized_validation_tokens_for_sites
    tokens = []
    Site.all.each { |site| tokens << site.new_validation_token }
    expected = Site.count
    got = tokens.uniq.size
    assert expected == got, "got #{got} instead of #{expected}"
  end
  
  def test_validation_token_attribute_should_not_be_accessible
    site = create_site(:validation_token => 'abc123')
    assert site.validation_token.nil?, "validation_token was set through Site.new"
    site.update_attributes('validation_token' => 'acb123')
    assert site.validation_token.nil?, "validation_token was set through update_attributes"
  end
  
  def test_validation_timestamp_attribute_should_not_be_accessible
    site = create_site(:validation_timestamp => 1.year.ago)
    assert site.validation_timestamp.nil?, "validation_timestamp was set through Site.new"
    site.update_attributes('validation_timestamp' => 1.year.ago)
    assert site.validation_timestamp.nil?, "validation_timestamp was set through update_attributes"
  end
  
  def test_should_update_validation_timestamp_when_generating_a_new_validation_token
    site = sites(:linkedin)
    site.new_validation_token
    site.reload
    recently = 1.minute.ago..1.minute.from_now
    assert recently.include?(site.validation_timestamp)
  end
  
  def test_should_be_able_verify_validation_tokens
    site = sites(:linkedin)
    valid_token = site.new_validation_token
    assert valid_token == site.verify_validation_token(valid_token)
  end
  
  def test_should_be_able_to_sniff_out_bad_validation_tokens
    site = sites(:linkedin)
    invalid_token = 'total bullshit'
    valid_token = site.new_validation_token
    assert valid_token != site.verify_validation_token(invalid_token)
    assert !site.verify_validation_token(invalid_token)
  end

  def test_should_regenerate_validation_token_if_not_verified
    site = sites(:linkedin)
    invalid_token = 'total bullshit'
    valid_token = site.new_validation_token
    old_timestamp = site.validation_timestamp
    assert !site.verify_validation_token(invalid_token)
    assert valid_token != site.validation_token
    assert old_timestamp != site.validation_timestamp
  end
  
  def test_should_not_regenerate_current_validation_tokens
    site = sites(:linkedin)
    valid_token = site.new_validation_token
    timestamp = site.validation_timestamp
    assert site.verify_validation_token(valid_token)
    assert valid_token = site.validation_token
    assert timestamp = site.validation_timestamp
  end
  
  def test_should_regenerate_validation_token_if_more_than_4_hours_old
    site = sites(:linkedin)
    valid_token = site.new_validation_token
    old_timestamp = 4.hours.ago - 1
    site.validation_timestamp = old_timestamp
    assert valid_token != site.verify_validation_token(valid_token)
    assert valid_token != site.validation_token
    assert old_timestamp != site.validation_timestamp
  end
  
  def test_should_set_the_name_based_on_the_title_of_the_home_page_after_being_created
    site = create_site(:url => "http://www.yahoo.com/")
    # expected = 'Yahoo!' # the value of the <title> tag of the above URL
    expected = 'www.yahoo.com'
    got = site.name
    assert got == expected, "got #{got} instead of #{expected}"
  end
  
  
end
