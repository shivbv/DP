class TwitterResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(twitter_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/twitterresponsehandler.log")
		identifier = "XXXX #{twitter_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
				"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.parse(response)
		if response
			user_website  = response.css('.ProfileHeaderCard-url span a.u-textUserColor')[0] != nil ?
				response.css('.ProfileHeaderCard-url span a.u-textUserColor')[0]['title'] : "not found"
			user_location = response.css('.ProfileHeaderCard-location span')[1] != nil ?
				response.css('.ProfileHeaderCard-location span')[1].text.strip : "Not Found"
			user_follower_count = response.search('span.ProfileNav-value')[2] != nil ?
				response.search('span.ProfileNav-value')[2].text : "Not Found"
		end
		return user_website, user_location, user_follower_count
	end

	def self.perform(task_id, twitter_info_id, response_code, response_file)
		logger = create_logger(twitter_info_id)
		twitter_info = TwitterInfo.find(twitter_info_id)
		task = Task.find(task_id)
		if response_code == 200
			mechanize = Mechanize.new
			response = mechanize.get("file:///#{Rails.root.to_s}/#{response_file}")
			user_website, user_location, user_follower_count = parse(response)
			twitter_info.update_attributes!(:status => TwitterInfo::Status::PARSED, :user_website => user_website,
					:user_location => user_location, :user_follower_count => user_follower_count)
		else
			twiiter_info.update_attributes!(:status => TwitterInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		twitter_info.update_attributes!(:status => TwitterInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end
end
