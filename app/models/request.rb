class Request
	def self.getrequest(url, parameters, referer, headers, proxy, logger = Logger.new(STDOUT))
		logger.info "CALLSERVER : #{parameters} : #{referer} : #{headers}"
		mechanize = Mechanize.new
		if proxy
			ip, port = proxy.split(":")
			mechanize.set_proxy ip, port
		end
		response = mechanize.get(url, parameters, referer, headers)
		logger.info "CALLRESPONSE : #{response.code}"
		return response
	rescue => e
		logger.error "CALLBACKFAILED : #{e.message}"
		raise e
	end

	def self.postrequest(url, query, headers, logger = Logger.new(STDOUT))
		logger.info "CALLSERVER : #{url} : #{query} : #{headers}"
		mechanize = Mechanize.new
		response = mechanize.post(url, query, headers)
		logger.info "CALLRESPONSE : #{response.code}"
		return response
	rescue => e
		logger.error "CALLBACKFAILED : #{e.message}"
		raise e
	end

	def self.formsubmit(response, website, form_action, field_id, logger = Logger.new(STDOUT))
		form = response.form_with(:action => form_action)
		form.field_with(:id => field_id).value = website
		res = form.submit
		logger.info "FORMSUBMITTED : "
		return res
	rescue => e
		logger.error "FORMSUBMISSIONFAIELD : #{e.message}"
		raise e
	end

	def self.getwhois(url, logger = Logger.new(STDOUT))
		response = Whois.whois(url)
		logger.info "REQUESTSUBMITTED : "
		return response
	rescue => e
		logger.error "WHOISFAILED : #{e.message}"
		raise e
	end

end
