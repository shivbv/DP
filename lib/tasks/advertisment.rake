namespace :advertisment do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.batch_create(urls)
		ads_infos = AdvertismentInfo.batch_create(sites)
		task = Task.create('ADVERTISMENT', inputfile, outputfile, urls.length)
		puts [task.id, 'Advertisment']
		ads_infos.each { |ads_info|
			Resque.enqueue(WebRequestJob, 'GET', ads_info.url, {}, {'action' => 'AdvertismentResponseHandlerJob', 
					'task_id' => task.id, 'id' => ads_info.id })
		}
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		ads_infos = AdvertismentInfo.where(:site => sites)
		ads_infos.each { |ads_info|
			ads_info.website.each { |link|
			puts [link.url, link.type]
		}
	end
end
