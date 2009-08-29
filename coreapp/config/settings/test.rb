SimpleConfig.for :application do
  set :port, "2010"
  set :domain, "localhost:#{port}"
  set :url, "http://#{domain}"
  set :selenium_demo_port, "2009"
  set :selenium_demo_domain, "localhost:#{selenium_demo_port}"
  set :selenium_demo_url, "http://#{selenium_demo_domain}/demo"
end
