class WhoisRequestJob
	def self.queue
		:whoisrequest
	end

	def self.create_logger(url)
		logger = Logger.new("#{Rails.root.to_s}/log/whois_request.log")
		identifier = "XXXX #{url} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
											"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.perform(type, url, event)
		logger = create_logger(url)
		logger.info "WHOISREQUEST : #{url} - #{event}"
		res_file = Digest::MD5.hexdigest(url + event['id'].to_s)
		res = Whois.whois(url)
		res_file = res_file + ".html"
		File.open(res_file,'wb+'){ |file|
			file << res
		}
		Resque.enqueue(event['action'].constantize, event['task_id'], event['id'], '200', res_file)
	rescue => e
		logger.error "REQUESTFAILED : #{e.message}" 
	end
end
