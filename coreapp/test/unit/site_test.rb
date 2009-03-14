require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false

  test 'should create site' do
    assert_difference 'Site.count' do
      site = create_site(:url => "http://google.com")
      assert !site.new_record?, "#{site.errors.full_messages.to_sentence}"
    end
  end

  test 'should require an account' do
    assert_no_difference "Site.count" do
      site = create_site(:url => "http://google.com", :account => nil)
      assert site.errors.on(:account_id)
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
    site = create_site(:url => "http://google.com/")
    %w(about contact_us FAQ).each do |page|
      site.pages << Page.new(:url => site.home_page.url + page)
    end
    ordered_pages = Page.find_by_sql "SELECT * FROM pages p WHERE p.site_id = #{site.id} ORDER BY created_at ASC"
    assert site.pages == ordered_pages
  end
  
  test 'should require at least one page' do
    url = "http://yahoo.com/"
    site = create_site(:url => url)
    assert site.pages.size >= 1, "Site has at least one page"
    assert site.pages[0].url == url, "Site's home_page's url is its first page's url"
  end
  
  test 'should delete all pages when deleted' do
    base_url = "http://google.com/"
    site = nil
    assert_difference "Site.count", 1 do
      site = create_site(:url => base_url)
    end
    
    page_urls = %w(maps movies alerts)
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
    url = "http://yahoo.com/"
    site = create_site(:url => url)
    assert site.pages[0] == site.home_page
  end
  
  test "can't change a site's home_page once created" do 
    site = create_site(:url => "http://google.com")
    new_page = create_page()
    site.home_page = new_page
    assert site.errors.on_base
    assert site.home_page != new_page
  end
  
  test "can't create a site with a nil url" do 
    assert_no_difference "Site.count" do
      site = create_site(:url => nil)
    end
  end
  
  # :url => nil and no url specified hit different validations
  test "can't create a site with no url specified" do
    assert_no_difference "Site.count" do
      site = Site.create(:account => commenters(:aaron))
    end
  end
  
  test "site isn't valid without a home page" do
    site = create_site(:url => nil)
    assert(! site.valid?)
  end
  
  test 'should be able to get url via Site#url' do
    url = "http://google.com"
    site = create_site(:url => url)
    assert site.url == url
  end
  
  test 'changeing site.url raises exception' do
    url = "http://google.com"
    site = create_site(:url => url)
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

end
