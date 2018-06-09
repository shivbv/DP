class WebsiteResponseHandlerJob
	
	def self.queue
		:responsehandler
	end
	
	def self.create_logger(web_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/websiteresponsehandler.log")
		identifier = "XXXX #{web_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
			"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end
	
	def self.perform(task_id, web_info_id, response_code, response_file)
		logger = create_logger(web_info_id)
		web_info = WebsiteInfo.find(web_info_id)
		task = Task.find(task_id)
		if response_code == "200"
			mechanize = Mechanize.new
			response = mechanize.get("file:///#{Rails.root.to_s}/#{response_file}")
			emails = response.body.scan(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/).flatten
			if emails != []
				emails.uniq!
				emails.each { |email| Email.create(web_info_id, email)  }
			end	
			web_info.update_attributes!(:status => WebsiteInfo::Status::PARSED)
		else
			web_info.update_attributes!(:status => WebsiteInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		web_info.update_attributes!(:status => SimilarWebInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end

end
