module AuthenticatedTestHelper
  # Sets the current account in the session from the account fixtures.
  def login_as(account)
    @request.session[:account_id] = account ? (account.is_a?(Account) ? account.id : commenters(account).id) : nil
  end

  def authorize_as(account)
    @request.env["HTTP_AUTHORIZATION"] = account ? ActionController::HttpAuthentication::Basic.encode_credentials(commenters(account).email, 'monkey') : nil
  end

  def assert_login_required
    assert_redirected_to new_session_path
  end
  
end
