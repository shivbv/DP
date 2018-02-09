class RestApiResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(ra_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/restapiresponsehandler.log")
		identifier = "XXXX #{ra_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
				"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.perform(task_id, ra_info_id, response_code, response_file)
		logger = create_logger(ra_info_id)
		ra_info = RestApiInfo.find(ra_info_id)
		task = Task.find(task_id)
		if response_code == 200
			profiles = JSON.parse(File.read(response_file))
			profiles.each { |profile|
				gravatar_url = profile['avatar_urls']['24'] || "" if profile['avatar_urls']
				User.create(ra_info_id, profile['id'], profile['name'], profile['url'], profile['description'], 
						profile['link'], gravatar_url) 
			}	
		else
			ra_info.update_attributes!(:status => RestApiInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		ra_info.update_attributes!(:status => RestApiInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end

end
