task :backup do
  timestamp = Time.now.utc.strftime("%Y%m%d%H%M") 
  Rake::Task['db:dump'].invoke
  backup_tar = "/mnt/backup/#{timestamp}_outspokes_db.tar.gz"
  `tar -czf #{backup_tar} db/schema.rb db/data.yml`
  `scp #{backup_tar} staging.outspokes.com:/mnt/backup`
end

task :load_backup do
  backup_tar = "/mnt/backup/" + Dir.entries("/mnt/backup").sort.last
  puts "loading backup #{backup_tar}..."
  `cp #{backup_tar} .`
  `tar -xzvf #{backup_tar}`
  Rake::Task['db:load'].invoke
end
