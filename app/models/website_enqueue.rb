class WebsiteEnqueue

	def self.create_logger(url)
		logger ||= Logger.new("#{Rails.root.to_s}/log/website_enqueue.log")
		identifier = "XXXX #{url} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
										"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.insert(web_infos_ids, task_id)
		web_infos = WebsiteInfo.where(:id => web_infos_ids)
		mechanize = Mechanize.new
		web_infos.each { |web_info|
			begin
				url = web_info.url
				logger = create_logger(url)
				res_file = Digest::MD5.hexdigest(url)
				res_file = res_file + ".html"
				response = mechanize.get(url)
				File.open(res_file, 'wb+'){ |file|
					file.write(response.body)
				}
				urls = response.links.collect { |link| link.href if link.href =~ /about/ || link.href =~ /contact/ }
				urls.uniq!
				urls.each { |url|
					Resque.enqueue(WebRequestJob, 'GET', url, {}, {'action' => 'WebsiteResponseHandlerJob',
							'task_id' => task_id, 'id' => web_info.id })
				}
				logger.info "WEBSITEENQUEUED : #{url}"
				Resque.enqueue(WebsiteResponseHandlerJob , task_id, web_info.id, response.code, res_file)
			rescue => e
				logger.error "WEBSITEENQUEINGFAILED : #{e.message}"
			end
		}
	end
end
