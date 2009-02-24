Users want to know that nobody can masquerade as them.  We want to extend trust
only to visitors who present the appropriate credentials.  Everyone wants this
identity verification to be as secure and convenient as possible.

Story: Logging in
  As an anonymous <%= file_name %> with an account
  I want to log in to my account
  So that I can be myself

  #
  # Log in: get form
  #
  Scenario: Anonymous <%= file_name %> can get a login form.
    Given an anonymous <%= file_name %>
    When  she goes to /login
    Then  she should be at the new <%= controller_file_name %> page
     And  the page should look AWESOME
     And  she should see a <form> containing a textfield: <%= (options[:email_as_login]) ? 'Email' : 'Login' %>, password: Password, and submit: 'Log in'
  
  #
  # Log in successfully, but don't remember me
  #
  Scenario: Anonymous <%= file_name %> can log in
    Given an anonymous <%= file_name %>
     And  an activated <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %>
<% if options[:email_as_login] -%>
    When  she creates a singular <%= controller_file_name %> with email: 'registered@example.com', password: 'monkey', remember me: ''
<% else -%>
    When  she creates a singular <%= controller_file_name %> with login: 'reggie', password: 'monkey', remember me: ''
<% end -%>
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %> should be logged in
     And  she should not have an auth_token cookie
   
  Scenario: Logged-in <%= file_name %> who logs in should be the new one
    Given an activated <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %>
     And  an activated <%= file_name %> logged in as <%= (options[:email_as_login]) ? 'unactivated@example.com' : 'oona' %>
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email: 'registered@example.com'" : "login: 'reggie'" %>, password: 'monkey', remember me: ''
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %> should be logged in
     And  she should not have an auth_token cookie
  
  #
  # Log in successfully, remember me
  #
  Scenario: Anonymous <%= file_name %> can log in and be remembered
    Given an anonymous <%= file_name %>
     And  an activated <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %>
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email: 'registered@example.com'" : "login: 'reggie'" %>, password: 'monkey', remember me: '1'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %> should be logged in
     And  she should have an auth_token cookie
	      # assumes fixtures were run sometime
     And  her session store should have <%= file_name %>_id: 4
   
  #
  # Log in unsuccessfully
  #
  
  Scenario: Logged-in <%= file_name %> who fails logs in should be logged out
    Given an activated <%= file_name %> named <%= (options[:email_as_login]) ? 'unactivated@example.com' : 'oona' %>
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email: 'unactivated@example.com'" : "login: 'oona'" %>, password: '1234oona', remember me: '1'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  <%= (options[:email_as_login]) ? 'unactivated@example.com' : 'oona' %> should be logged in
     And  she should have an auth_token cookie
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email: registered@example.com" : "login: 'reggie'" %>, password: 'i_haxxor_joo'
    Then  she should be at the new <%= controller_file_name %> page
    Then  she should see an error message 'Couldn't log you in as <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %>'
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have <%= file_name %>_id
  
  Scenario: Log-in with bogus info should fail until it doesn't
    Given an activated <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %>
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email: registered@example.com" : "login: 'reggie'" %>, password: 'i_haxxor_joo'
    Then  she should be at the new <%= controller_file_name %> page
    Then  she should see an error message 'Couldn't log you in as <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %>'
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have <%= file_name %>_id
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email: registered@example.com" : "login: 'reggie'" %>, password: ''
    Then  she should be at the new <%= controller_file_name %> page
    Then  she should see an error message 'Couldn't log you in as <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %>'
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have <%= file_name %>_id
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email" : "login" %>: '', password: 'monkey'
    Then  she should be at the new <%= controller_file_name %> page
    Then  she should see an error message 'Couldn't log you in as '''
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have <%= file_name %>_id
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email: leonard_shelby@example.com" : "login: 'leonard_shelby'" %>, password: 'monkey'
    Then  she should be at the new <%= controller_file_name %> page
    Then  she should see an error message 'Couldn't log you in as 'leonard_shelby<%= "@example.com" if options[:email_as_login] %>''
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have <%= file_name %>_id
    When  she creates a singular <%= controller_file_name %> with <%= (options[:email_as_login]) ? "email: registered@example.com" : "login: 'reggie'" %>, password: 'monkey', remember me: '1'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %> should be logged in
     And  she should have an auth_token cookie
	      # assumes fixtures were run sometime
     And  her session store should have <%= file_name %>_id: 4


  #
  # Log out successfully (should always succeed)
  #
  Scenario: Anonymous (logged out) <%= file_name %> can log out.
    Given an anonymous <%= file_name %>
    When  she goes to /logout
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'You have been logged out'
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have <%= file_name %>_id

  Scenario: Logged in <%= file_name %> can log out.
    Given an activated <%= file_name %> logged in as <%= (options[:email_as_login]) ? 'registered@example.com' : 'reggie' %>
    When  she goes to /logout
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'You have been logged out'
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have <%= file_name %>_id
