class WebRequestJob < Struct.new(:site_id, :url, :params, :type, :event)
	def logger
		logger ||= Logger.new("#{Rails.root.to_s}/log/logfile.log")
		identifier = "XXXX #{url} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
																					 "#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def perform
		debugger
		res_file = Digest::MD5.hexdigest(url)
		if type == 'GET'
			response = RestClient.get(url, params)
			res_code = response.code
		else 
			response = RestClient.post(url, params)
			res_code = response.code
		end
		File.open(res_file,'a+'){ |file|
			file << response.body
		}
		arr = [event, url, res_code, res_file]
		WEB_REQUEST_REDIS.set(site_id, arr.inspect)
	rescue => e
	logger.error "REQUESTFAILED : #{e.message}" 	
	end
end
