class WebRequestJob < Struct.new(:type, :url, :params, :event)
	def logger
		logger ||= Logger.new("#{Rails.root.to_s}/log/web_requests.log")
		identifier = "XXXX #{url} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
						   	 "#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def perform
		params_str = params.map{|k,v| "#{k}=#{v}"}.join(',')
		res_file = Digest::MD5.hexdigest(url+params_str)
		res = RestClient::Request.execute(:method => type.to_sym, :url => url, :headers => {:params => params})
		res_code = res.code
		File.open(res_file,'ab+'){ |file|
			file << res.body
		}
		Resque.enqueue(event[:action], event[:id] , event[:task_id], url, response_code, res_file)
	rescue => e
	logger.error "REQUESTFAILED : #{e.message}" 	
	end
end
