namespace :word_press do
	task :check => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile) 
		sites = Site.batch_create(urls)
		wp_infos = WordPressInfo.batch_create(sites)
		task = Task.create('WORDPRESS', inputfile, outputfile, urls.length)
		task_id = task.id
		puts [task.id, 'WordPress']
		wp_infos.each { |wp_info|
			key = "#{task_id}_#{wp_info.id}"
			QUEUE_NO_RATE_LIMIT.set(key, ['GET', wp_info.url, {},
													 {:action => 'WordPressResponseHandlerJob', :task_id=> task_id, :id => wp_info.id }].to_json)
		}
		ThrottlerJob.new.perform
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		wp_infos = WordPressInfo.where(:site => sites)
		wp_infos.each { |wp_info|
			puts [wp_info.site.url, wp_info.check]
		} 
	end
end

