require 'test_helper'

class VerifyFixturesTest < ActionController::IntegrationTest
  fixtures :all

  # Replace this with your real tests.
  test "all fixtures are valid" do
    classes = [Commenter, Feedback, Invite, Page, Site]
    classes.each do |cls|
      cls.find(:all).each do |fixture|
        assert fixture.valid?, "The object #{fixture.inspect} is invalid. Errors: #{fixture.errors.inspect}"
      end
    end
  end
end
