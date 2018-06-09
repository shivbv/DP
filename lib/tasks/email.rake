namespace :email do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile) 
		sites = Site.batch_create(urls)
		web_infos = WebsiteInfo.batch_create(sites)
		task = Task.create('EMAIL', inputfile, outputfile, urls.length)
		puts [task.id, 'EMAIL']
		WebsiteEnqueue.insert(web_infos.ids, task.id)
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		web_infos = WebsiteInfo.where(:site => sites)
		web_infos.each { |web_info|
			web_info.email.each { |website_email|
				puts [website_email.email]
		}
		}
	end
end

