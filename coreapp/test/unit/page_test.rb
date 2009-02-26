require 'test_helper'

class PageTest < ActiveSupport::TestCase

  test 'should create page' do
    assert_difference 'Page.count' do
      page = create_page
      assert !page.new_record?, "#{page.errors.full_messages.to_sentence}"
    end
  end
  
  test 'should also create page with Site instead of Account' do
    assert_difference 'Page.count' do
      page = Page.create(valid_options_for_page_site)
      assert !page.new_record?, "#{page.errors.full_messages.to_sentence}"
    end
  end
  
  test 'cannot create a page with both sites and accounts' do
    assert_no_difference 'Page.count' do
      page = create_page(valid_options_for_page_site)
      assert page.errors.on_base, "allowing pages to be created with an account and a site"
    end
  end
  
  test 'cannot create a page without a site or an account' do
    assert_no_difference 'Page.count' do
      page = Page.create(valid_options_for_page_account.merge({ :account_id => nil }))
      assert page.errors.on_base, "allowing pages to be created with no account or site"
    end
  end
  
  test 'should require a URL' do
    assert_no_difference "Page.count" do
      page = create_page(:url => nil)
      assert page.errors.on(:url), "allowing pages to be created without a url"
    end
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
        page = create_page(:url => scheme + '://example.com')
        assert !page.new_record?, "#{page.errors.full_messages.to_sentence}"
      end
    end
  end
end
