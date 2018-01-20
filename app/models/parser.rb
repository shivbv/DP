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
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				traffic_estimate = res.search("div#ctl00_cphMainContent_ucGoogleMonthlyChart_pnlEstimateOnly div.chart-yoy span span span").text
				if traffic_estimate == ""
					traffic_estimate = res.search("span#ctl00_cphMainContent_estVisitsSpan").text
					traffic_estimate =  traffic_estimate.scan(/ estimated ([0-9,]+) /)
					traffic_estimate = traffic_estimate.join(",")
				end
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				puts [s_entity.url, traffic_estimate]
				logger.info "PARSEDSUCCESSFULLY :"
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
	end


	def self.scanbacklinks()
		scrap_entities = ScrapEntity.executed.scanbacklinks
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				da = res.search('.result-content span')[1].text
				pa = res.search('.result-content span')[2].text
				puts "#{da}  #{pa} "
				logger.info "PARSEDSUCCESSFULLY :"
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)	
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
	end

	def self.twitter
		scrap_entities = ScrapEntity.executed.twitter
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				website  = res.css('.ProfileHeaderCard-url span a.u-textUserColor')[0] != nil ?
					res.css('.ProfileHeaderCard-url span a.u-textUserColor')[0]['title'] : "not found"
					geography = res.css('.ProfileHeaderCard-location span')[1] != nil ?
					res.css('.ProfileHeaderCard-location span')[1].text.strip : "Not Found"
					follower_count = res.search('span.ProfileNav-value')[2] != nil ? res.search('span.ProfileNav-value')[2].text : "Not Found"
					puts "#{website}  #{geography}  #{follower_count} "
					s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			else
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
	end

	def self.webhost
		scrap_entities = ScrapEntity.executed.webhost
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				a_tag = res.search("header.align-center")[0]
				value1 = a_tag.search('a').text
				value2 = a_tag.search('h2').text
				if value1 == nil || value1 =~ /^Click Here/
					puts value2
				else
					puts [value1, value2]
				end
				logger.info "PARSEDSUCCESSFULLY :"
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
	end

	def self.restapi
		scrap_entities = ScrapEntity.executed.restapi
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				res_ar = JSON.parse(res.body)
				res_ar.each { |response|
					users = JSON.parse(response)
					users.each { |user|
						puts "#{user["id"]}  #{user["name"]}   #{user["url"]}  #{user["description"]} #{user["link"]} "
					}
				}
				logger.info "PARSEDSUCCESSFULLY :"
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
	end

	def self.checkwp
		scrap_entities = ScrapEntity.executed.checkwp
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				puts "WP SITE"	if res.body =~ /wp-content/ || res.body =~ /wp-uploads/
					logger.info "PARSEDSUCCESSFULLY :"
					s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
			end
		}
	rescue => e
		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

	def self.whois
		scrap_entities = ScrapEntity.executed.whois
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			registrant_name = ""
			organization_name = ""
			registrant_state = ""
			registrant_country = ""
			registrant_email = ""
			admin_email = ""
			name_server = Array.new
			res.body.to_s.each_line { |line|
				if registrant_name == "" && line =~ /Registrant Name:/
					registrant_name = line.gsub(/Registrant Name:/,"")
				end
				if organization_name == "" && line =~ /Registrant Organization:/
					organization_name = line.gsub(/Registrant Organization:/,"")
				end
				if registrant_state == "" && line=~ /Registrant State\/Province:/
					registrant_state = line.gsub(/Registrant State\/Province:/,"")
				end
				if registrant_country == "" && line=~ /Registrant Country:/
					registrant_country = line.gsub(/Registrant Country:/,"")
				end
				if registrant_email == "" && line=~ /Registrant Email:/
					registrant_email = line.gsub(/Registrant Email:/,"")
				end
				if admin_email == "" && line =~ /Admin Email:/
					admin_email = line.gsub(/Admin Email:/,"")
				end
				if(line =~ /^Name Server: /)
					name_server.push(line.gsub(/Name Server:/,""))
				end
			}
			puts [registrant_name, organization_name, registrant_state, registrant_country, registrant_email, admin_email]
			logger.info "PARSEDSUCCESSFULLY :"
			s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
		}
	rescue => e
		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

	def self.article_details
		scrap_entities = ScrapEntity.executed.article_details
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				article_title = res.at('meta[property="og:title"]') ? res.at('meta[property="og:title"]')[:content].strip : "NF"
				if article_title == "NF"
					article_title = res.title != nil ? res.title.strip : "NF"
				end
				time_published = res.at('meta[property="article:published_time"]')?res.at('meta[property="article:published_time"]')[:content]:"NF"
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
	
	def self.safebrowsing
		scrap_entities = ScrapEntity.executed.safebrowsing
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			data = JSON.parse(res.body)
			urls = []
			matches = data["matches"]
			if matches != nil
			matches.each { |entry|
				urls << entry["threat"]["url"]
			}
			end
			urls.uniq!
			puts urls
			s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
		}
	rescue => e
 		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

end
