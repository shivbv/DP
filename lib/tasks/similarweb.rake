namespace :similar_web do
	task :fetch => :environment do
		urls = BvLib.parse_urls_file	
		Site.connection
		sites = Site.batch_create(urls)
		swinfos = SimilarWebInfo.batch_create(sites)
		swinfos.each { |swinfo|
			Resque.enque(WebRequestJob, swinfo.id, swinfo.url, nil, 'GET', 'SIMILARWEB')
		}
	end
end
