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
				if s_entity.category == ScrapEntity::Category::SCANBACKLINKS
					res = Request.formsubmit_id(response, params[:website], 'check-da-form', 'checkform-site', logger)
				elsif s_entity.category == ScrapEntity::Category::WEBHOST
					res = Request.formsubmit_no(response, params[:website], 0, 'url', logger)
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
