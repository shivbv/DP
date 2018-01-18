class Executer
	def self.queue
		:execute
	end

	def self.perform(ids_array)
		s_entities = ScrapEntity.find(ids_array)
		response = nil
		s_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				url = s_entity.url
				params = s_entity.params
				headers = params[:headers] || {}
				referer = params[:referer]
				parameters = params[:parameters] || []
				response = Request.callback(url, parameters, referer, headers, logger) if response == nil
				if s_entity.category == ScrapEntity::Category::SCANBACKLINKS || s_entity.category == ScrapEntity::Category::WEBHOST
					form_action = params[:action]
					field_id = params[:field_with]
					res = Request.formsubmit(response, params[:website], form_action, field_id, logger)
				elsif s_entity.category == ScrapEntity::Category::RESTAPI
					jsonarray = []
					for index in 1..10000
						request_url = "#{url}?page=#{index}"
						res = Request.callback(request_url, parameters, referer, headers, logger)
						break if res.body == '[]'
						jsonarray << res.body
					end
					s_entity.file_write(jsonarray)
					s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTED)
					next
				else
					res = Request.callback(url, parameters, referer, headers, logger)
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
