class Executer
	def self.queue
		:execute
	end
	@proxy = []

	def self.proxy_list
		File.open('/home/sumit/proxyfile/proxy.txt').each_line{ |proxy|
			@proxy << proxy
		}
	end

	def self.perform(scrapentity_ids)
		s_entities = ScrapEntity.find(scrapentity_ids)
		proxy_list
		count = 0
		s_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				url = s_entity.url
				params = s_entity.params
				headers = params[:headers] || {}
				referer = params[:referer]
				parameters = params[:parameters] || []
				body = ""
				if s_entity.category == ScrapEntity::Category::TRAFFICESTIMATE
					count += 1
					if count == 30
						sleep 120
						count = 0
					end
					sleep(2)
					res = Request.getrequest(url, parameters, referer, headers, nil, logger)
					body = res.body + " "
				elsif s_entity.category == ScrapEntity::Category::EXTRACTEMAIL
					res = Request.getrequest(url, parameters, referer, headers, nil, logger)
					body = res.body
					urls = []
					if res.links != nil
						res.links.each { |link| urls << link.href if link.href =~ /about/ || link.href =~ /about/ }
					end
					if urls.uniq! != nil
					urls.each { |url|
						begin
						res = Request.getrequest(url, parameters, referer, headers, nil, logger)
						body += res.body + ""
						rescue => e
							logger.error "PAGEOPENFAILED : #{e.message}"
						end
					}
					end
				elsif s_entity.category == ScrapEntity::Category::SAFEBROWSING
					key = params[:key]
					url = url + key
					query = params[:query]
					res = Request.postrequest(url, query.to_json, headers, logger)
					body = res.body
				elsif s_entity.category == ScrapEntity::Category::SCANBACKLINKS || s_entity.category == ScrapEntity::Category::WEBHOST
					@response ||= Request.getrequest(url, parameters, referer, headers, nil, logger)
					form_action = params[:action]
					field_id = params[:field_with]
					res = Request.formsubmit(@response, params[:website], form_action, field_id, logger)
					body = res.body
				elsif s_entity.category == ScrapEntity::Category::RESTAPI
					resarray = []
					for index in 1..10000
						request_url = "#{url}?page=#{index}"
						res = Request.getrequest(request_url, parameters, referer, headers, nil, logger)
						break if res.body == '[]'
						resarray << res.body
					end
					body = resarray
				elsif s_entity.category == ScrapEntity::Category::WHOIS || s_entity.category == ScrapEntity::Category::WHOSIP
					res = Request.getwhois(url, logger)
					body = res.to_s
				else
					res = Request.getrequest(url, parameters, referer, headers, nil, logger)
					body = res.body
				end
				s_entity.file_write(body)
				s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTED)
			rescue => e
				logger.error "EXECUTIONFAILED : #{e.message}"
				s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTIONFAILED)
			end
		}
	end

end
