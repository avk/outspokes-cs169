SimpleConfig.for :application do
  set :domain, "beta.outspokes.com"
  set :url, "http://#{domain}"
  set :twitter, "http://twitter.com/outspokes"

  group :emails do
    set :admin, "Outspokes <admin@outspokes.com>"
    set :support, "support@outspokes.com"
    set :feedback, "feedback@outspokes.com"
    set :no_reply, "Outspokes <outspokes-no-reply@outspokes.com>"
  end
end
