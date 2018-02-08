namespace :scan_back_link do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.batch_create(urls)
		sbl_infos = ScanBackLinkInfo.batch_create(sites)
		task = Task.create('SCANBACKLINK', inputfile, outputfile, urls.length)
		puts task.id
		sbl_infos.each { |sbl_info|
			Resque.enqueue(WebRequestJob, 'GET', sbl_info.url, {}, {'action' => 'ScanBackLinkResponseHandlerJob',
					'task_id' => task.id, 'id' => sbl_info.id })
		}
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		sbl_infos = ScanBackLinkInfo.where(:site => sites)
		sbl_infos.each { |sbl_info|
			puts [sbl_info.da, sbl_info.pa]
		}
	end
end
