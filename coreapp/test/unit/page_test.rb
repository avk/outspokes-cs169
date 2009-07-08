require File.dirname(__FILE__) + '/../test_helper'

class PageTest < ActiveSupport::TestCase

  test 'should create page' do
    assert_difference 'Page.count' do
      page = create_page
      assert !page.new_record?, "#{page.errors.full_messages.to_sentence}"
    end
  end

  test 'should also create page with site' do
    assert_difference 'Page.count' do
      page = Page.create(valid_options_for_page_site)
      assert !page.new_record?, "#{page.errors.full_messages.to_sentence}"
    end
  end

  test 'should require a URL' do
    assert_no_difference "Page.count" do
      page = create_page(:url => nil)
      assert page.errors.on(:url), "allowing pages to be created without a url"
    end
  end
  
  test "should be able to add a URL after adding to site's pages" do
    site = sites(:linkedin)
    new_page = site.pages.create
    assert new_page.new_record?
    assert !new_page.valid?
    new_page.url = site.url + "/this/doesnt/exist"
    assert new_page.valid?
    assert new_page.save
    assert !new_page.new_record?
  end

  test 'should not accept invalid URLs' do
    assert_no_difference "Page.count" do
      page = create_page(:url => 'abc@#$@#saf432s')
      assert page.errors.on(:url), "allowing page to be created with invalid URLs"
    end
  end

  test 'should not accept invalid URL scheme' do
    %w(ftp ssh git svn).each do |scheme|
      assert_no_difference "Page.count" do
        page = create_page(:url => scheme + '://example.com')
        assert page.errors.on(:url), "allowing page with an invalid URL scheme: #{scheme}"
      end
    end
  end

  test 'should only accept the http and https URL schemes' do
    %w(http https).each do |scheme|
      assert_difference "Page.count" do
        page = create_page(:url => scheme + '://msn.com')
        assert !page.new_record?, "#{page.errors.full_messages.to_sentence}"
      end
    end
  end

  test 'should have a unique URL for a given site' do
    assert_difference "Page.count", 1 do
      page = Page.create(valid_options_for_page_site)
      assert !page.new_record?, "#{page.errors.full_messages.to_sentence}"
      page = Page.create(valid_options_for_page_site)
      assert page.errors.on(:url), "allowing one site to have multiple pages with the same URL"
    end
  end
  
  test "throw an exception when setting URL for a page has a site" do
    page = Page.create(valid_options_for_page_site)
    assert_raise RuntimeError do
      page.url = "http://neopets.com"
    end
  end

  test "can't add a page to a site with the wrong domain" do
    site = sites(:facebook)
    page = Page.new(:url => "http://google.com", :site => site)
    assert ! page.valid?
  end

  test 'should respond to commenters' do
    assert create_page.respond_to?(:commenters)
  end

  test 'should delete all associated feedback instances when deleted' do
    page = nil

    assert_difference "Page.count", 1 do
      page = create_page
    end

    comments = %w(sucks boo yuck)
    assert_difference "Feedback.count", comments.size do
      comments.each do |comment|
        page.feedbacks << create_comment(:content => comment)
      end
      page.save
    end

    assert_difference "Page.count", -1 do
      assert_difference "Feedback.count", -(comments.size) do
        page.destroy
      end
    end
  end
  
  test 'should delete all associated invites when deleted' do
    page = create_page
    commenters = %w(aaron)

    assert_difference "Invite.count", commenters.size do
      commenters.each do |name|
        page.invites << Invite.new(:commenter => commenters(name))
      end
      page.save
    end
    
    assert_difference "Page.count", -1 do
      # 1 commenters, and 1 admin account of the site
      assert_difference "Invite.count", -(commenters.size + 1) do
        page.destroy
      end
    end
  end
  
  test 'should delegate it\'s account to it\'s site' do
    page = Page.first
    assert page.account == page.site.account
  end

end
