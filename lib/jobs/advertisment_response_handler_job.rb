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
			category = -1
			category = Website::Category::DEAL if link.href =~ /deal/i
			category = Website::Category::ADVERT if link.href =~ /advert/i
			category = Website::Category::COUPON if link.href =~ /coupon/i
			category = Website::Category::GIVEAWAY if link.href =~ /giveaway/i
			category = Website::Category::PODCAST if link.href =~ /podcast/i
			category = Website::Category::OFFER if link.href =~ /offer/i
			category = Website::Category::DISCOUNT if link.href =~ /discount/i	
			Website.create(ads_info.id, link.href, category) if category != -1
		}
	end

	def self.perform(task_id, ads_info_id, response_code, response_file)
		logger = create_logger(ads_info_id)
		ads_info = AdvertismentInfo.find(ads_info_id)
		task = Task.find(task_id)
		if response_code == 200
			mechanize = Mechanize.new
			response = mechanize.get("file:///#{Rails.root.to_s}/#{response_file}")
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
