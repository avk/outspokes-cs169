# TODO: put into Cron module and test it
task :cron => :environment do
  start_time = Time.now
  if start_time.hour.zero?
    puts "Running nightly tasks..."
  end

  puts "Running hourly tasks..."
  Notification.pending.each do |notification|
    notification.deliver!
  end
end
