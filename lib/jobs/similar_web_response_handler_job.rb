class SimilarWebResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(swinfo_id)
		logger = Logger.new("#{Rails.root.to_s}/log/similarwebresponsehandler.log")
		identifier = "XXXX #{swinfo_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
			"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.parse(data)
		global_rank = data['GlobalRank']['Rank'] if data['GlobalRank']
		traffic = data['Engagments']['Visits']  if data['Engagments']
		category = data['Category']
		if data['TopCategoriesAndFills']
			topcategories = data['TopCategoriesAndFills'].collect{ |category| category['Category'] }.join(", ")
		end
		toptags = data['TopTagsAndStrength'].collect{ |tag| tag['Tag']}.join(", ") if data['TopTagsAndStrength']
		description = data['Description']
		return global_rank, traffic, category, topcategories, toptags, description
	end

	def self.perform(task_id, swinfo_id, response_code, response_file)
		logger = create_logger(swinfo_id)
		swinfo = SimilarWebInfo.find(swinfo_id)
		task = Task.find(task_id)
		if response_code == 200
			data = JSON.parse(File.read(response_file))
			puts global_rank, traffic, category, topcategories, toptags, description = parse(data)
			swinfo.update_attributes!(:status => SimilarWebInfo::Status::PARSED, :global_rank => global_rank, 
					:traffic => traffic, :category => category, :topcategories => topcategories, 
					:description => description, :toptags => toptags)
		else
			swinfo.update_attributes!(:status => SimilarWebInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		swinfo.update_attributes!(:status => SimilarWebInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end
end
