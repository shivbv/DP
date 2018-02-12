class WordPressResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(wp_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/word_press_response_handler.log")
		identifier = "XXXX #{wp_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
										 					"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.perform(task_id, wp_info_id, response_code, response_file)
		logger = create_logger(wp_info_id)
		wp_info = WordPressInfo.find(wp_info_id)
		task = Task.find(task_id)
		if response_code == 200
			mechanize = Mechanize.new
			response = mechanize.get("file://#{response_file}")
			check = 'no'
			check = 'yes' if response && response.body =~ /wp-content/ || response.body =~ /wp-uploads/
			wp_info.update_attributes!(:status => WordPressInfo::Status::PARSED, :check => check)
		else
			wp_info.update_attributes!(:status => WordPressInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		wp_info.update_attributes!(:status => WordPressInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end
end
