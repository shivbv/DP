class GravatarProfileResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(gp_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/gravatarprofileresponsehandler.log")
		identifier = "XXXX #{gp_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
				"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.parse(data)
		entry = data['entry'][0]
		if entry
			name = entry['displayName']
			about_user = entry['aboutMe']
			location = entry['currentLocation']
			phone_numbers = entry['phoneNumbers']
			phone_numbers = phone_numbers.collect {|phonenumber| phonenumber['value'] }.join(",") if phone_numbers
			emails = entry['emails']
			emails = emails.collect{|email| email['value'] }.join(",") if emails
			social_accounts = entry['accounts']
			social_accounts = social_accounts.collect {|account| account['url'] }.join(",") if social_accounts
			websites = entry['urls']
			websites = websites.collect{|website| website['value'] }.join(",") if websites
		end
		return name, about_user, location, phone_numbers, emails, social_accounts, websites
	end

	def self.perform(task_id, gp_info_id, response_code, response_file)
		logger = create_logger(gp_info_id)
		gp_info = GravatarProfileInfo.find(gp_info_id)
		task = Task.find(task_id)
		if response_code == '200'
			data = JSON.parse(File.read(response_file))
			name, about_user, location, phone_numbers, emails, social_accounts, websites = parse(data)
			gp_info.update_attributes!(:status => GravatarProfileInfo::Status::PARSED, :name => name, 
					:about_user => about_user, :location => location, :phone_numbers => phone_numbers, 
					:emails => emails, :social_accounts => social_accounts, :websites => websites)
		else
			gp_info.update_attributes!(:status => GravatatProfileInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		gp_info.update_attributes!(:status => GravatarProfileInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end
end

