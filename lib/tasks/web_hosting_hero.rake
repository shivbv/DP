namespace :web_hosting_hero do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.batch_create(urls)
		whh_infos = WebHostingHeroInfo.batch_create(sites)
		task = Task.create('WEBHOSTINGHERO', inputfile, outputfile, urls.length)
		puts task.id
		whh_infos.each { |whh_info|
			Resque.enqueue(WebHostingHeroResponseHandlerJob, task.id, whh_info.id)
		}
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		whh_infos = WebHostingHeroInfo.where(:site => sites)
		whh_infos.each { |whh_info|
			puts [whh_info.site.url, whh_info.webhost]
		}
	end
end

