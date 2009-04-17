class Mailer < ActionMailer::Base

  #Avinash 4q survey 

  # Crap demo method
  def mail(person)
    from        "outspokes@reallycooldomainname.com"
    recipients  person.email
    subject     "You have been invited to give a feedback!"
    sent_on     Time.now
    
    body        :person => person
  end  

end
