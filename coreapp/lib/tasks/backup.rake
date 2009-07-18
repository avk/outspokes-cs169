task :backup do
  timestamp = Time.now.utc.strftime("%Y%m%d%H%M") 
  Rake::Task['db:dump'].invoke
  `tar -czf /mnt/backup/#{timestamp}_outspokes_db.tar.gz db/schema.rb db/data.yml`
end
