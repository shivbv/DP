namespace :whois do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile) 
		sites = Site.batch_create(urls)
		whois_infos = WhoisInfo.batch_create(sites)
		task = Task.create('Whois', inputfile, outputfile, urls.length)
		puts [task.id, 'Whois']
		whois_infos.each { |whois_info|
			Resque.enqueue(WhoisRequestJob, 'GET', whois_info.url, {'action' => 'WhoisResponseHandlerJob', 
					'task_id' => task.id, 'id' => whois_info.id })
		}
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		whois_infos = WhoisInfo.where(:site => sites)
		whois_infos.each { |whois_info|
			puts [whois_info.registrant_name, whois_info.organization_name, whois_info.registrant_state, 
					whois_info.registrant_country, whois_info.registrant_email, whois_info.admin_email]
		} 
	end
end
