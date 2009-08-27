# used by Selenium for testing
class DemoController < ApplicationController
  before_filter :require_test_environment

  def index
  end

  def about
  end

  def tps
  end

  protected
  def require_test_environment
    raise ActionController::RoutingError.new('No route found') unless RAILS_ENV == 'test'
  end
end
