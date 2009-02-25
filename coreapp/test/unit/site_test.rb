require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  test 'should create site' do
    assert_difference 'Site.count' do
      site = create_site
      assert !site.new_record?, "#{site.errors.full_messages.to_sentence}"
    end
  end
  
  test 'should require a URL' do
    assert_no_difference "Site.count" do
      site = create_site(:url => nil)
      assert site.errors.on(:url), "allowing sites to be created without a url"
    end
  end
  
  test 'should not accept invalid URLs' do
    assert_no_difference "Site.count" do
      site = create_site(:url => 'abc@#$@#saf432s')
      assert site.errors.on(:url), "allowing sites to be create with invalid URLs"
    end
  end

  test 'should not accept invalid URL scheme' do
    %w(ftp ssh git svn).each do |scheme|
      assert_no_difference "Site.count" do
        site = create_site(:url => scheme + '://example.com')
        assert site.errors.on(:url), "allowing sites with an invalid URL scheme: #{scheme}"
      end
    end
  end

  test 'should only accept the http and https URL schemes' do
    %w(http https).each do |scheme|
      assert_difference "Site.count" do
        site = create_site(:url => scheme + '://example.com')
        assert !site.new_record?, "#{site.errors.full_messages.to_sentence}"
      end
    end
  end

end
