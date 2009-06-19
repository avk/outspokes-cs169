SimpleConfig.for :application do
  set :domain, "beta.outspokes.com"
  set :url, "http://#{domain}"

  group :emails do
    set :admin, "Outspokes <admin@outspokes.com>"
    set :support, "Outspokes <support@outspokes.com>"
    set :no_reply, "Outspokes <outspokes-no-reply@outspokes.com>"
  end
end
