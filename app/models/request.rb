class Request
	def self.callback(url, parameters, referer, headers, logger = Logger.new(STDOUT))
		tries ||= 2
		mechanize = Mechanize.new
		logger.info "CALLSERVER : #{parameters} : #{referer} : #{headers}"
		response = mechanize.get(url, parameters, referer, headers)
		logger.info "CALLRESPONSE : #{response.code}"
		return response
	rescue => e
		logger.error "CALLBACKRETRY : try#{tries} : #{e.message}"
		retry if !(tries -= 1).zero?
		logger.error "CALLBACKFAILED : #{e.message}"
		raise e
	end

	def self.formsubmit(response, website, form_action, field_id, logger = Logger.new(STDOUT))
		form = response.form_with(:action => form_action)
		form.field_with(:id => field_id).value = website
		form.submit
	rescue => e
		logger.error "FORMSUBMISSIONFAIELD : #{e.message}"
	end

end
