class ScanBackLinkResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(sbl_info_id)
		logger = Logger.new("#{Rails.root.to_s}/log/scanbacklinkresponsehacdler.log")
		identifier = "XXXX #{sbl_info_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
				"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.perform(task_id, sbl_info_id)
		logger = create_logger(sbl_info_id)
		sbl_info = ScanBackLinkInfo.find(sbl_info_id)
		response = sbl_info.get_response
		task = Task.find(task_id)
		if response.code == '200'
			form = response.form_with(:action => '/check-dapa')
			form.field_with(:id => 'checkform-site').value = sbl_info.site.url
			form_response = form.submit
			da = form_response.search('.result-content span')[1].text
			pa = form_response.search('.result-content span')[2].text
			sbl_info.update_attributes!(:status => ScanBackLinkInfo::Status::PARSED, :da => da, :pa => pa)
		else
			sbl_info.update_attributes!(:status => ScanBackLinkInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		sbl_info.update_attributes!(:status => ScanBackLinkInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end
end
