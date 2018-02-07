namespace :similar_web do
	task :fetch => :environment do
		urls = BvLib.parse_urls_file	
		sites = Site.batch_create(urls)
		swinfos = SimilarWebInfo.batch_create(sites)
		swinfos.each { |swinfo|
			Resque.enque(WebRequestJob, 'GET', swinfo.url, {}, {'action' => 'SimilarWebResponseHandlerJob', 
				'task_id' => task.id, 'id' => swinfo.id }
		}
	end
end
