class Executer
	def self.queue
		:execute
	end
	@proxy = []
	@response = nil
	def self.proxy_list
		File.open('/home/sumit/proxyfile/proxy.txt').each_line{|proxy|
				@proxy << proxy
		}
	end

	def self.perform(ids_array)
		s_entities = ScrapEntity.find(ids_array)
		proxy_list
		s_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				url = s_entity.url
				params = s_entity.params
				headers = params[:headers] || {}
				referer = params[:referer]
				parameters = params[:parameters] || []
				if s_entity.category == ScrapEntity::Category::SAFEBROWSING
					key = params[:key]
					url = url+key
					query = params[:query]
					res = Request.postrequest(url, query.to_json, headers, logger)
				elsif s_entity.category == ScrapEntity::Category::SCANBACKLINKS || s_entity.category == ScrapEntity::Category::WEBHOST
					@response = Request.callback(url, parameters, referer, headers, nil, logger) if @response == nil
					form_action = params[:action]
					field_id = params[:field_with]
					res = Request.formsubmit(@response, params[:website], form_action, field_id, logger)
				elsif s_entity.category == ScrapEntity::Category::RESTAPI
					resarray = []
					for index in 1..10000
						request_url = "#{url}?page=#{index}"
						res = Request.callback(request_url, parameters, referer, headers, nil, logger)
						break if res.body == '[]'
						resarray << res.body
					end
					s_entity.file_write(resarray)
					s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTED)
					next
				elsif s_entity.category == ScrapEntity::Category::WHOIS
					res = Request.getwhois(url,logger)
					s_entity.file_write(res.to_s)
					s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTED)
					next
				else
					res = Request.callback(url, parameters, referer, headers, nil, logger)
				end
				s_entity.file_write(res.body)
				s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTED)
			rescue => e
				logger.error "EXECUTIONFAILED : #{e.message}"
				s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTIONFAILED)
			end
		}
	end

end
