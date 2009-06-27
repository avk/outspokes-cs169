task :cron => :environment do
  start_time = Time.now
  if start_time.hour.zero?
    puts "Running nightly tasks..."
    todays_feedbacks = Feedback.all(:conditions => ["created_at BETWEEN ? AND ?", 
                                      (start_time - 1.day).beginning_of_day,
                                      (start_time.beginning_of_day)
                                    ])
    Mailer.deliver_feedback_notification(todays_feedbacks)
    puts "done."
  end
end
