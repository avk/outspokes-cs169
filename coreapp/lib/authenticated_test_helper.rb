module AuthenticatedTestHelper
  # Sets the current account in the session from the account fixtures.
  def login_as(account)
    @request.session[:account_id] = account ? (account.is_a?(Account) ? account.id : accounts(account).id) : nil
  end

  def authorize_as(account)
    @request.env["HTTP_AUTHORIZATION"] = account ? ActionController::HttpAuthentication::Basic.encode_credentials(accounts(account).email, 'monkey') : nil
  end
  
end
