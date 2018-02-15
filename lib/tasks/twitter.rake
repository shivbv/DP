namespace :twitter do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.batch_create(urls)
		twitter_infos = TwitterInfo.batch_create(sites)
		task = Task.create('TWITTER', inputfile, outputfile, urls.length)
		puts task.id
		twitter_infos.each { |twitter_info|
			Resque.enqueue(WebRequestJob, 'GET', twitter_info.url, {}, {'action' => 'TwitterResponseHandler',
					'task_id' => task.id, 'id' => twitter_info.id })
		}
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

