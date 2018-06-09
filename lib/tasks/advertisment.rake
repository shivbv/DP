namespace :advertisment do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.batch_create(urls)
		ads_infos = AdvertismentInfo.batch_create(sites)
		task = Task.create('ADVERTISMENT', inputfile, outputfile, urls.length)
		task_id = task.id
		puts [task.id, 'Advertisment']
		ads_infos.each { |ads_info|
			key = "#{task_id}_#{ads_info.id}"
			QUEUE_NO_RATE_LIMIT.set(key, ['GET', ads_info.url, {},
													 {:action => 'AdvertismentResponseHandlerJob', :task_id=> task_id, :id => ads_info.id }].to_json)
		}
		ThrottlerJob.new.perform	
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		ads_infos = AdvertismentInfo.where(:site => sites)
		ads_infos.each { |ads_info|
			puts "****#{ads_info.url} *******"
			ads_info.website.each { |link|
			puts [link.url, link.category]
		}
		}
	end
end
