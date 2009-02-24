Visitors should be in control of creating an account and of proving their
essential humanity/accountability or whatever it is people think the
id-validation does.  We should be fairly skeptical about this process, as the
identity+trust chain starts here.

Story: Creating an account
  As an anonymous <%= file_name %>
  I want to be able to create an account
  So that I can be one of the cool kids

  #
  # Account Creation: Get entry form
  #
  Scenario: Anonymous <%= file_name %> can start creating an account
    Given an anonymous <%= file_name %>
    When  she goes to /signup
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  the page should look AWESOME
     And  she should see a <form> containing a <%= "textfield: Login," unless options[:email_as_login] %> textfield: Email, password: Password, password: 'Confirm Password', submit: 'Sign up'

  #
  # Account Creation
  #
  Scenario: Anonymous <%= file_name %> can create an account
    Given an anonymous <%= file_name %>
<% if options[:email_as_login] -%>
    And  no <%= file_name %> with email: 'unactivated@example.com' exists
<% else -%>
    And  no <%= file_name %> with login: 'Oona' exists
<% end -%>

<% if options[:email_as_login] -%>
    When  she registers an account as the preloaded 'unactivated@example.com'
<% else -%>
    When  she registers an account as the preloaded 'Oona'
<% end -%>
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Thanks for signing up!'
<% if options[:email_as_login] -%>
    And  a <%= file_name %> with email: 'unactivated@example.com' should exist
    And  the <%= file_name %> should have email: 'unactivated@example.com'
<% else -%>
    And  a <%= file_name %> with login: 'oona' should exist
    And  the <%= file_name %> should have login: 'oona', and email: 'unactivated@example.com'
<% end -%> 
<% if options[:include_activation] %>
     And  the <%= file_name %>'s activation_code should not be nil
     And  the <%= file_name %>'s activated_at    should     be nil
     And  she should not be logged in
<% else %>
     And  <%= (options[:email_as_login]) ? 'unactivated@example.com' : 'oona' %> should be logged in
<% end %>

  #
  # Account Creation Failure: Account exists
  #
<% if options[:include_activation] %>
  Scenario: Anonymous <%= file_name %> can not create an account replacing a non-activated account
    Given an anonymous <%= file_name %>
     And  a registered <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'Reggie' %>
     And  the <%= file_name %> has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
<% if options[:email_as_login] -%>
     When  she registers an account with email: 'registered@example.com' and password: 'monkey'
<% else -%>
     When  she registers an account with login: 'reggie', password: 'monkey', and email: 'different@example.com'
<% end -%>         
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
<% if options[:email_as_login] -%>
     And  she should     see an errorExplanation message 'Email has already been taken'
<% else -%>
     And  she should     see an errorExplanation message 'Login has already been taken'
     And  she should not see an errorExplanation message 'Email has already been taken'
<% end -%>
<% unless options[:email_as_login] -%>
     And  a <%= file_name %> with login: 'reggie' should exist
<% end -%>
     And  the <%= file_name %> should have email: 'registered@example.com'
     And  the <%= file_name %>'s activation_code should not be nil
     And  the <%= file_name %>'s activated_at    should     be nil
     And  the <%= file_name %>'s created_at should stay the same under to_s
     And  the <%= file_name %>'s updated_at should stay the same under to_s
     And  she should not be logged in<% end %>
     
  Scenario: Anonymous <%= file_name %> can not create an account replacing an activated account
    Given an anonymous <%= file_name %>
     And  an activated <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'Reggie' %>
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
<% if options[:email_as_login] -%>
     When  she registers an account with email: 'registered@example.com' and password: 'monkey'
<% else -%>
     When  she registers an account with login: 'reggie', password: 'monkey', and email: 'reggie@example.com'
<% end -%>
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
<% if options[:email_as_login] -%>
     And  she should     see an errorExplanation message 'Email has already been taken'
<% else -%>
     And  she should     see an errorExplanation message 'Login has already been taken'
     And  she should not see an errorExplanation message 'Email has already been taken'
<% end -%>
<% unless options[:email_as_login] -%>
     And  a <%= file_name %> with login: 'reggie' should exist
<% end -%>
     And  the <%= file_name %> should have email: 'registered@example.com'
<% if options[:include_activation] %>
     And  the <%= file_name %>'s activation_code should     be nil
     And  the <%= file_name %>'s activated_at    should not be nil<% end %>
     And  the <%= file_name %>'s created_at should stay the same under to_s
     And  the <%= file_name %>'s updated_at should stay the same under to_s
     And  she should not be logged in

  #
  # Account Creation Failure: Incomplete input
  #
  Scenario: Anonymous <%= file_name %> can not create an account with incomplete or incorrect input
    Given an anonymous <%= file_name %>
<% if options[:email_as_login] -%>
     And  no <%= file_name %> with email: 'unactivated@example.com' exists
    When  she registers an account with email: '',     password: 'monkey', and password_confirmation: 'monkey'
<% else -%>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: '',     password: 'monkey', password_confirmation: 'monkey' and email: 'unactivated@example.com'
<% end -%>
    Then  she should be at the '<%= model_controller_routing_path %>/new' page     
<% if options[:email_as_login] -%>
    And  she should     see an errorExplanation message 'Email can't be blank'
    And  no <%= file_name %> with email: 'unactivated@example.com' should exist
<% else -%>
    And  she should     see an errorExplanation message 'Login can't be blank'
    And  no <%= file_name %> with login: 'oona' should exist
<% end -%>
     
     
  Scenario: Anonymous <%= file_name %> can not create an account with no password
    Given an anonymous <%= file_name %>
<% if options[:email_as_login] -%>
     And  no <%= file_name %> with email: 'unactivated@example.com' exists
    When  she registers an account with email: 'unactivated@example.com',     password: '', and password_confirmation: 'monkey'
<% else -%>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: '',       password_confirmation: 'monkey' and email: 'unactivated@example.com'
<% end -%>
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Password can't be blank'
<% if options[:email_as_login] -%>
    And  no <%= file_name %> with email: 'unactivated@example.com' should exist
<% else -%>
    And  no <%= file_name %> with login: 'oona' should exist
<% end -%>
     
  Scenario: Anonymous <%= file_name %> can not create an account with no password_confirmation
    Given an anonymous <%= file_name %>
<% if options[:email_as_login] -%>
     And  no <%= file_name %> with email: 'unactivated@example.com' exists
    When  she registers an account with email: 'unactivated@example.com', password: 'monkey', and password_confirmation: ''
<% else -%>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: ''       and email: 'unactivated@example.com'
<% end -%>
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Password confirmation can't be blank'
<% if options[:email_as_login] -%>
    And  no <%= file_name %> with email: 'unactivated@example.com' should exist
<% else -%>
    And  no <%= file_name %> with login: 'oona' should exist
<% end -%>
     
  Scenario: Anonymous <%= file_name %> can not create an account with mismatched password & password_confirmation
    Given an anonymous <%= file_name %>
<% if options[:email_as_login] -%>
     And  no <%= file_name %> with email: 'unactivated@example.com' exists
    When  she registers an account with email: 'unactivated@example.com', password: 'monkey', and password_confirmation: 'monkeY'
<% else -%>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkeY' and email: 'unactivated@example.com'
<% end -%>
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Password doesn't match confirmation'
<% if options[:email_as_login] -%>
    And  no <%= file_name %> with email: 'unactivated@example.com' should exist
<% else -%>
    And  no <%= file_name %> with login: 'oona' should exist
<% end -%>
     
  Scenario: Anonymous <%= file_name %> can not create an account with bad email
    Given an anonymous <%= file_name %>
<% if options[:email_as_login] -%>
    When  she registers an account with email: '', password: 'monkey', and password_confirmation: 'monkey'
<% else -%>
     And  no <%= file_name %> with login: 'Oona' exists
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkey' and email: ''
<% end -%>
    Then  she should be at the '<%= model_controller_routing_path %>/new' page
     And  she should     see an errorExplanation message 'Email can't be blank'
<% if options[:email_as_login] -%>
     And  no <%= file_name %> with email: 'unactivated@example.com' should exist
    When  she registers an account with email: 'unactivated@example.com', password: 'monkey', and password_confirmation: 'monkey'
<% else -%>
     And  no <%= file_name %> with login: 'oona' should exist
    When  she registers an account with login: 'oona', password: 'monkey', password_confirmation: 'monkey' and email: 'unactivated@example.com'
<% end -%>
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Thanks for signing up!'
<% if options[:email_as_login] -%>
     And  a <%= file_name %> with email: 'unactivated@example.com' should exist
<% else -%>
     And  a <%= file_name %> with login: 'oona' should exist
     And  the <%= file_name %> should have login: 'oona', and email: 'unactivated@example.com'
<% end -%>
<% if options[:include_activation] %>
     And  the <%= file_name %>'s activation_code should not be nil
     And  the <%= file_name %>'s activated_at    should     be nil
     And  she should not be logged in
<% else %>
     And  <%= (options[:email_as_login]) ? 'unactivated@example.com' : 'oona' %> should be logged in
<% end %>
     
<% if options[:include_activation] %>
Story: Activating an account
  As a registered, but not yet activated, <%= file_name %>
  I want to be able to activate my account
  So that I can log in to the site

  #
  # Successful activation
  #
  Scenario: Not-yet-activated <%= file_name %> can activate her account
    Given a registered <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'Reggie' %>
     And  the <%= file_name %> has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
    When  she goes to /activate/activate_me
    Then  she should be redirected to 'login'
    When  she follows that redirect!
    Then  she should see a notice message 'Signup complete!'
<% if options[:email_as_login] -%>
     And  a <%= file_name %> with email: 'registered@example.com' should exist
<% else -%>
     And  a <%= file_name %> with login: 'reggie' should exist
     And  the <%= file_name %> should have login: 'reggie', and email: 'registered@example.com'
<% end -%>
     And  the <%= file_name %>'s activation_code should     be nil
     And  the <%= file_name %>'s activated_at    should not be nil
     And  she should not be logged in

  #
  # Unsuccessful activation
  #
  Scenario: Not-yet-activated <%= file_name %> can't activate her account with a blank activation code
    Given a registered <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'Reggie' %>
     And  the <%= file_name %> has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
    When  she goes to /activate/
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see an error  message 'activation code was missing'
<% if options[:email_as_login] -%>
     And  a <%= file_name %> with email: 'registered@example.com' should exist
     And  the <%= file_name %> should have email: 'registered@example.com', activation_code: 'activate_me', and activated_at: nil!
<% else -%>
     And  a <%= file_name %> with login: 'reggie' should exist
     And  the <%= file_name %> should have login: 'reggie', activation_code: 'activate_me', and activated_at: nil!
<% end -%>
     And  the <%= file_name %>'s updated_at should stay the same under to_s
     And  she should not be logged in
  
  Scenario: Not-yet-activated <%= file_name %> can't activate her account with a bogus activation code
    Given a registered <%= file_name %> named <%= (options[:email_as_login]) ? 'registered@example.com' : 'Reggie' %>
     And  the <%= file_name %> has activation_code: 'activate_me', activated_at: nil! 
     And  we try hard to remember the <%= file_name %>'s updated_at, and created_at
    When  she goes to /activate/i_haxxor_joo
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see an error  message 'couldn\'t find a <%= file_name %> with that activation code'
<% if options[:email_as_login] -%>
     And  a <%= file_name %> with email: 'registered@example.com' should exist
     And  the <%= file_name %> should have email: 'registered@example.com', activation_code: 'activate_me', and activated_at: nil!
<% else -%>
     And  a <%= file_name %> with login: 'reggie' should exist
     And  the <%= file_name %> should have login: 'reggie', activation_code: 'activate_me', and activated_at: nil!
<% end -%>
     And  the <%= file_name %>'s updated_at should stay the same under to_s
     And  she should not be logged in
<% end %>
