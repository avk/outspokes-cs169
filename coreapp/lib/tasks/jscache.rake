namespace :jscache do
  
  desc "clear the page cached JavaScript from FeedbackjsController#index"
  task :clear => :environment do
    cache_dir = ActionController::Base.page_cache_directory
    
    # since index is the default controller action, it can be cached in two ways:
    %w(feedbackjs.html feedbackjs/index.html).each do |page_cache_file|
      begin
        if page_cache_file.match /(.*)\/.*\.html/ # directory/file.html
          dir = cache_dir + '/' + $1
          puts "removing #{dir}"
          FileUtils.rm_rf(dir)
        else # file.html
          path = cache_dir + '/' + page_cache_file
          puts "removing #{path}"
          FileUtils.rm(path)
        end
      rescue
        puts "Path doesn't exist."
      end
    end    
  end
end