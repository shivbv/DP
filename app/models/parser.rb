class Parser
	def self.get_response(s_entity)
		mechanize = Mechanize.new
		res = mechanize.get("file:///#{s_entity.filename}")
	end

	def self.similarweb()
		scrap_entities = ScrapEntity.executed.similarweb
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				data = JSON.parse(res.body)
				global_rank = data["GlobalRank"]["Rank"]
				estimatted_traffic = data["Engagments"]["Visits"]
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			else
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
	rescue => e
		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

	def self.trafficestimate()
		scrap_entities = ScrapEntity.executed.trafficestimate
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				traffic_estimate = res.search("div#ctl00_cphMainContent_ucGoogleMonthlyChart_pnlEstimateOnly div.chart-yoy span span span").text
				if traffic_estimate == ""
					traffic_estimate = res.search("span#ctl00_cphMainContent_estVisitsSpan").text
					traffic_estimate =  traffic_estimate.scan(/ estimated ([0-9,]+) /)
					traffic_estimate = traffic_estimate.join(",")
				end
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				puts [site, traffic_estimate]
				logger.info "PARSEDSUCCESSFULLY :"
			else
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
	rescue
		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

=begin
	def self.scanbacklink()
		scrap_entities = ScrapEntity.executed.scanbacklinks
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
					form = res.form_with(:id => 'check-da-form')

					form.field_with(:id => 'checkform-site').value = "dzone.com"
			end
		}
	end
=end

	def twitter
		scrap_entities = ScrapEntity.executed.twitter
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				website  = res.css('.ProfileHeaderCard-url span a.u-textUserColor')[0] != nil ?
									 res.css('.ProfileHeaderCard-url span a.u-textUserColor')[0]['title'] : "not found"
				geography = page.css('.ProfileHeaderCard-location span')[1] != nil ?
										page.css('.ProfileHeaderCard-location span')[1].text.strip : "Not Found"
				follower_count = page.search('span.ProfileNav-value')[2] != nil ? page.search('span.ProfileNav-value')[2].text : "Not Found"
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			else
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
	end

end
