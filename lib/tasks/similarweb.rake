namespace :similar_web do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)	
		sites = Site.batch_create(urls)
		swinfos = SimilarWebInfo.batch_create(sites)
		task = Task.create('SIMILARWEB', inputfile, outputfile, urls.length)
		swinfos.each { |swinfo|
			Resque.enque(WebRequestJob, 'GET', swinfo.url, {}, {'action' => 'SimilarWebResponseHandlerJob', 
					'task_id' => task.id, 'id' => swinfo.id })
		}
	end
end
