require File.dirname(__FILE__) + '/../test_helper'

class VerifyFixturesTest < ActionController::IntegrationTest
  fixtures :all

  test "all fixtures are valid" do
    classes = [Commenter, Feedback, Invite, Page, Site, Notification]
    classes.each do |cls|
      cls.find(:all).each do |fixture|
        begin
          assert fixture.valid?, "The object #{fixture.inspect} is invalid. Errors: #{fixture.errors.full_messages.to_sentence}"
        rescue Exception => e
          assert false, "'#{fixture.inspect}' fixture.valid? caused exception: #{e.message}"
        end
      end
    end
  end

  test "all sites should have an invite for it's admin user" do
    Site.all.each do |site|
      site.home_page.invites.map(&:commenter).include?(site.account)
    end
  end

  test "all sites should have an admin url" do
    Site.all.each do |site|
      begin
        assert site.admin_url, "admin url must exist"
      rescue Exception => e
        assert false, "site.admin_url caused an exception: '#{site.inspect}'\n #{site.url}"
      end
    end
  end
    
end
