Rake tasks to run specs and tests in parallel, to use multiple CPUs and speedup test runtime.

Setup
=====

For this fork (to be removed before pulling upstream):

    script/plugin install git://github.com/jasonm/parallel_specs.git

For the upstream plugin:

    script/plugin install git://github.com/grosser/parallel_specs.git

Add <%= ENV['TEST_ENV_NUMBER'] %> to the database name for the test environment in `config/database.yml`,  
it is '' for process 1, and '2' for process 2.

    test:
      adapter: mysql
      database: xxx_test<%= ENV['TEST_ENV_NUMBER'] %>
      username: root

For each environment, create the databases
    mysql -u root -> create database xxx_test2;

Run like hell :D  

    rake spec:parallel:prepare[2] #db:reset for each database

    rake spec:parallel[1] --> 86 seconds
    rake spec:parallel    --> 47 seconds (default = 2)
    rake spec:parallel[4] --> 26 seconds
    ...

Example output
--------------
    2 processes for 210 specs, ~ 105 specs per process
    ... test output ...

    Results:
    877 examples, 0 failures, 11 pending
    843 examples, 0 failures, 1 pending

    Took 29.925333 seconds

Test::Unit
----------

To run Test::Unit tests, use the following task:

    rake test:parallel

instead of

    rake spec:parallel

This includes the ability to specify more than two parallel environments.

TIPS
====
 - `./script/generate rspec` if you are running rspec from gems (this plugin uses script/spec which may fail if rspec files are outdated)
 - with zsh this would be `rake "spec:parallel:prepare[3]"`

TODO
====
 - find out how many CPUs the user has [here](http://stackoverflow.com/questions/891537/ruby-detect-number-of-cpus-installed)
 - grab the 'xxx examples ..' line and display them after all tests have finished

Authors
====
inspired by [pivotal labs](http://pivotallabs.com/users/miked/blog/articles/849-parallelize-your-rspec-suite)  

###Contributors
 - [Joakim Kolsjö](http://www.rubyblocks.se) -- joakim.kolsjo<$at$>gmail.com
 - [Jason Morrison](http://jayunit.net) -- jason.p.morrison<$at$>gmail.com

[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
