namespace :rest_api do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.batch_create(urls)
		ra_infos = RestApiInfo.batch_create(sites)
		task = Task.create('RESTAPI', inputfile, outputfile, urls.length)
		puts [task.id, 'RESTAPI']
		ra_infos.each { |ra_info|
			pages = RestClient.get(ra_info.url).headers[:x_wp_totalpages]
			if pages
				for index in 1..pages.to_i
					Resque.enqueue(WebRequestJob, 'GET', "#{ra_info.url}?page=#{index}", {}, {'action' => 
							'RestApiResponseHandlerJob', 'task_id' => task.id, 'id' => ra_info.id })
				end
			end
		}
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		ra_infos = RestApiInfo.where(:site => sites)
		ra_infos.each { |ra_info|
			ra_info.user.each { |user|
				puts [user.user_id, user.name, user.website, user.description, user.social_account, 
						user.gravatar_url]
			}
		}
	end
end


