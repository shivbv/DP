class WhoisResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(whois_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/whoisresponsehandler.log")
		identifier = "XXXX #{whois_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
			"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end
	
	def self.parse(response)
		if response
			registrant_name, organization_name, registrant_state, registrant_country, registrant_email, admin_email = 
					[nil, nil, nil, nil, nil, nil]
			response.body.each_line { |line|
				registrant_name ||= line.gsub(/Registrant Name:/,"") if line =~ /Registrant Name:/
				organization_name ||= line.gsub(/Registrant Organization:/,"") if line =~ /Registrant Organization:/
				registrant_state ||= line.gsub(/Registrant State\/Province:/,"") if line=~ /Registrant State\/Province:/
				registrant_country ||= line.gsub(/Registrant Country:/,"") if line=~ /Registrant Country:/
				registrant_email ||= line.gsub(/Registrant Email:/,"") if line=~ /Registrant Email:/
				admin_email ||= line.gsub(/Admin Email:/,"") if line =~ /Admin Email:/
			}
			registrant_state.force_encoding('UTF-8') if registrant_state
			organization_name.force_encoding('UTF-8') if organization_name
			registrant_name.force_encoding('UTF-8') if registrant_name
			registrant_country.force_encoding('UTF-8') if registrant_country
			registrant_email.force_encoding('UTF-8') if registrant_email
			admin_email.force_encoding('UTF-8') if admin_email	
			return registrant_name, organization_name, registrant_state, registrant_country, registrant_email, 
				admin_email
		end
	end

	def self.perform(task_id, whois_info_id, response_code, response_file)
		logger = create_logger(whois_info_id)
		whois_info = WhoisInfo.find(whois_info_id)
		task = Task.find(task_id)
		if response_code == '200'
			mechanize = Mechanize.new
			response = mechanize.get("file:///#{Rails.root.to_s}/#{response_file}")
			registrant_name, organization_name, registrant_state, registrant_country, registrant_email, 
					admin_email = parse(response)
			whois_info.update_attributes!(:registrant_name => registrant_name, :organization_name => organization_name,
					:registrant_state => registrant_state, :registrant_country => registrant_country, :registrant_email =>
					registrant_email, :admin_email => admin_email)
		else
			whois_info.update_attributes!(:status => WhoisInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		whois_info.update_attributes!(:status => WhoisInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end

end
