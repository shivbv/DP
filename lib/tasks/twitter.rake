namespace :twitter do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.batch_create(urls)
		twitter_infos = TwitterInfo.batch_create(sites)
		task = Task.create('TWITTER', inputfile, outputfile, urls.length)
	  task_id = task.id
		puts [task_id, 'Twitter']
		twitter_infos.each { |twitter_info|
			key = "#{task_id}_#{twitter_info.id}"
			QUEUE_TWO_MINUTE.set(key, ['GET', twitter_info.url, {},
													 {:action => 'TwitterResponseHandlerJob', :task_id=> task_id, :id => twitter_info.id }].to_json)
		}
		ThrottlerJob.new.perform_per_two_min
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		twitter_infos = TwitterInfo.where(:site => sites)
		twitter_infos.each { |twitter_info|
			puts [twitter_info.user_website, twitter_info.user_location, twitter_info.user_follower_count]
		}
	end
end

