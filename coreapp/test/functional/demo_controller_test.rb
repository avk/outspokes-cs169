require File.dirname(__FILE__) + '/../test_helper'

class DemoControllerTest < ActionController::TestCase
  %w(index about tps).each do |action|
    test "should get #{action}" do
      get action
      assert_template "demo/#{action}.html.erb"
    end
  end
end
