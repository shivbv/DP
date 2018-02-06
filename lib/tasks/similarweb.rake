namespace :similar_web do
	task :fetch => :environment do
		urls = BvLib.parse_file	
		sites = Site.create_site(urls)
		swinfos = SimilarWebInfo.create_sw_infos(sites)
		swinfos.each { |swinfo|
			Resque.enque(WebRequestJob, swinfo.id, swinfo.url, '', 'GET', 'SIMILARWEB')
		}
	end
end
