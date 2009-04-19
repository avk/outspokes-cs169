class Mailer < ActionMailer::Base

  #Avinash 4q survey 

  # Crap demo method
  def commenter_invite(person, page)
    from         "outspokes@reallycooldomainname.com"
    recipients   person.email
    subject      "You have been invited to give feedback!"
    sent_on      Time.now
    content_type "text/html"
    
    body         :person => person, :page => page 
  end  

end
