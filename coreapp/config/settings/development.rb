SimpleConfig.for :application do
  set :domain, "localhost:3000"
  set :url, "http://#{domain}"  
end
