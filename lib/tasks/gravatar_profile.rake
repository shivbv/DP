namespace :gravatar_profile do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile) 
		sites = Site.batch_create(urls)
		gp_infos = GravatarProfileInfo.batch_create(sites)
		task = Task.create('GRAVATAR', inputfile, outputfile, urls.length)
		task_id = task.id
		puts [task_id,'GRAVATAR']
		gp_infos.each { |gp_info|
			key = "#{task_id}_#{gp_info.id}"
			QUEUE_NO_RATE_LIMIT.set(key, ['GET', gp_info.url, {},
															{:action => 'GravatarProfileResponseHandlerJob', :task_id=> task_id, :id => gp_info.id }].to_json)
		}
		ThrottlerJob.new.perform
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		gp_infos = GravatarProfileInfo.where(:site => sites)
		gp_infos.each { |gp_info|
			puts [gp_info.name, gp_info.about_user, gp_info.location, gp_info.phone_numbers, gp_info.emails,
					gp_info.social_accounts, gp_info.websites]
		} 
	end
end

