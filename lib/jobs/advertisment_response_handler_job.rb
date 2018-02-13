class AdvertismentResponseHandlerJob

	def self.queue
		:responsehandler
	end

	def self.create_logger(ads_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/advertismentresponsehandler.log")
		identifier = "XXXX #{ads_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
			"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.parse(links, ads_info)
		links.each { |link|
			type = -1
			type = Website::Type::DEAL if link.href =~ /deal/i
			type = Website::Type::ADVERT if link.href =~ /advert/i
			type = Website::Type::COUPON if link.href =~ /coupon/i
			type = Website::Type::Giveaway if link.href =~ /giveaway/i
			type = Website::Type::PODCAST if link.href =~ /podcast/i
			type = Website::Type::OFFER if link.href =~ /offer/i
			type = Website::Type::DISCOUNT if link.href =~ /discount/i	
			debugger
			Website.create(ads_info.id, link.href, type) if type != -1
		}
	end

	def self.perform(task_id, ads_info_id, response_code, response_file)
		logger = create_logger(ads_info_id)
		ads_info = AdvertismentInfo.find(ads_info_id)
		task = Task.find(task_id)
		if response_code == 200
			mechanize = Mechanize.new
			response = mechanize.get("file://#{response_file}")
			debugger
			parse(response.links, ads_info)
			ads_info.update_attributes!(:status => AdvertismentInfo::Status::EXECUTIONFAILED)
		else
			ads_info.update_attributes!(:status => AdvertismentInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		ads_info.update_attributes!(:status => AdvertismentInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end

end
