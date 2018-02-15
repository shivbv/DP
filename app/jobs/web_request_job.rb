class WebRequestJob
	def self.queue
		:webrequest
	end

	def self.create_logger(url)
		logger = Logger.new("#{Rails.root.to_s}/log/web_requests.log")
		identifier = "XXXX #{url} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
			"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.perform(type, url, params, event)
		logger = create_logger(url)
		logger.info "WEBREQUEST : #{url} - #{params} - #{event}"
		params_str = params.map{|k,v| "#{k}=#{v}"}.join(',')
		res_file = Digest::MD5.hexdigest(url+params_str)
		res = RestClient::Request.execute(:method => type.to_sym, :url => url, :headers => {:params => params})
		res_code = res.code
		res_file = res_file + ".html"
		File.open(res_file,'wb+'){ |file|
			file << res.body
		}
		Resque.enqueue(event['action'].classify.constantize , event['task_id'], event['id'], res_code, res_file)
	rescue => e
		logger.error "REQUESTFAILED : #{e.message}"	
	end
end
