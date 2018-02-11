class WebHostingHeroResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(whh_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/webhsotingheroresponsehandler.log")
		identifier = "XXXX #{whh_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
				"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.perform(task_id, whh_info_id)
		logger = create_logger(whh_info_id)
		whh_info = WebHostingHeroInfo.find(whh_info_id)
		response = whh_info.get_response
		task = Task.find(task_id)
		if response.code == '200'
			form = response.form_with(:action => 'https://www.webhostinghero.com/who-is-hosting/')
			form.field_with(:id => 'url').value = whh_info.site.url
			form_response = form.submit
			list1 = form_response.search("ul.detail li")[5]
			list2 = form_response.search("ul.detail li")[6]
			webhost = list1.text if (list1 && list1.text =~ /ISP:/) 
			webhost = list2.text if (list2 && list2.text =~ /ISP:/)
			webhost.gsub!("ISP:","")
			whh_info.update_attributes!(:status => WebHostingHeroInfo::Status::PARSED, :webhost => webhost)
		else
			whh_info.update_attributes!(:status => WebHostingHeroInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		whh_info.update_attributes!(:status => WebHostingHeroInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end
end
