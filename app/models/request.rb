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

	def self.formsubmit_id(response, website, form_id, field_id, logger = Logger.new(STDOUT))
		form = response.form_with(:id => form_id)
		form.field_with(:id => field_id).value = website
		form.submit
	rescue => e
		logger.error "FORMSUBMISSIONFAIELD : #{e.message}"
	end

	def self.formsubmit_no(response, website, form_no, field_id, logger = Logger.new(STDOUT))
		form = response.forms[form_no]
		form.field_with(:id => field_id).value = website
		form.submit
	rescue => e
		logger.error "FORMSUBMISSIONFAIELD : #{e.message}"
	end

end
