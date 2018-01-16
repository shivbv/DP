class Executer
	def self.queue
		:execute
	end

	def self.perform(ids_array)
		s_entities = ScrapEntity.find(ids_array)	
		s_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				url = s_entity.url
				params = s_entity.params
				headers = params[:headers] || {}
				referer = params[:referer]
				parameters = params[:parameters] || []
				res = Request.callback(url, parameters, referer, headers, logger)
				s_entity.file_write(res.body)
				s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTED)
			rescue => e
				logger.error "EXECUTIONFAILED : #{e.message}"
				s_entity.update_attributes!(:status => ScrapEntity::Status::EXECUTIONFAILED)
			end
		}
	end
end
