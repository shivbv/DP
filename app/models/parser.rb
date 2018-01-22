class Parser
	def self.get_response(s_entity)
		mechanize = Mechanize.new
		res = mechanize.get("file:///#{s_entity.filename}")
	end

	def self.similarweb()
		file_name = ENV["filename"] || "/home/check.csv"
		scrap_entities = ScrapEntity.executed.similarweb
		keys = ['url', 'global_rank', 'estimated_traffic']
		values = []
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				data = JSON.parse(res.body)
				global_rank = data["GlobalRank"]["Rank"]
				estimatted_traffic = data["Engagments"]["Visits"]
				values << [s_entity.url, global_rank, estimatted_traffic]
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			else
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
		BvLib.write_file(file_name, keys, values)
	rescue => e
		BvLib.write_file(file_name, keys, values)
		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

	def self.trafficestimate()
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'estimated_traffic']
		values = []
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
				values << [s_entity.url, traffic_estimate]
				logger.info "PARSEDSUCCESSFULLY :"
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
		 BvLib.write_file(file_name, keys, values)
	end


	def self.scanbacklinks()
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'DA', 'PA']
		values = []
		scrap_entities = ScrapEntity.executed.scanbacklinks
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				da = res.search('.result-content span')[1].text
				pa = res.search('.result-content span')[2].text
				values << [s_entity.url, da, pa]
				logger.info "PARSEDSUCCESSFULLY :"
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)	
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.twitter
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'website', 'geography', 'follower_count']
		values = []
		scrap_entities = ScrapEntity.executed.twitter
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				website  = res.css('.ProfileHeaderCard-url span a.u-textUserColor')[0] != nil ?
					res.css('.ProfileHeaderCard-url span a.u-textUserColor')[0]['title'] : "not found"
				geography = res.css('.ProfileHeaderCard-location span')[1] != nil ?
					res.css('.ProfileHeaderCard-location span')[1].text.strip : "Not Found"
				follower_count = res.search('span.ProfileNav-value')[2] != nil ? 
					res.search('span.ProfileNav-value')[2].text : "Not Found"
				values << [s_entity.url, website, geography, follower_count]
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			else
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.webhost
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'webshost']
		values = []
		scrap_entities = ScrapEntity.executed.webhost
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				a_tag = res.search("header.align-center")[0]
				value1 = a_tag.search('a').text
				value2 = a_tag.search('h2').text
				if value1 == nil || value1 =~ /^Click Here/
					values << [s_entity.url, value2]
				else
					values << [s_entity.url, value1+" "+value2]
				end
				logger.info "PARSEDSUCCESSFULLY :"
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.restapi
		file_name = ENV["filename"] || "/home/check.csv"
    keys = ['url', 'user_id', 'user_name', 'user_url', 'description', 'link']
		values = []
		scrap_entities = ScrapEntity.executed.restapi
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				res_ar = JSON.parse(res.body)
				res_ar.each { |response|
					users = JSON.parse(response)
					users.each { |user|
						values << [s_entity.url, user["id"], user["name"], user["url"], user["description"], user["link"]]
					}
				}
				logger.info "PARSEDSUCCESSFULLY :"
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.checkwp
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'Site Status']
		values = []
		scrap_entities = ScrapEntity.executed.checkwp
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			if res != nil
				if res.body =~ /wp-content/ || res.body =~ /wp-uploads/
					values << [s_entity.url, 'WP SITE']
				else
					values << [s_entity.url, 'NOT WP SITE']
				end
				logger.info "PARSEDSUCCESSFULLY :"
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
			end
		}
		BvLib.write_file(file_name, keys, values)
	rescue => e
		BvLib.write_file(file_name, keys, values)
		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

	def self.whois
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'registrant_name', 'organization_name', 'registrant_state',
		        'registrant_country', 'registrant_email', 'admin_email']
		values = []
		scrap_entities = ScrapEntity.executed.whois
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			registrant_name = nil
			organization_name = nil
			registrant_state = nil
			registrant_country = nil
			registrant_email = nil
			admin_email = nil
			name_server = Array.new
			res.body.to_s.each_line { |line|
				registrant_name ||= line.gsub(/Registrant Name:/,"") if line =~ /Registrant Name:/
				organization_name ||= line.gsub(/Registrant Organization:/,"") if line =~ /Registrant Organization:/
				registrant_state ||= line.gsub(/Registrant State\/Province:/,"") if line=~ /Registrant State\/Province:/
				registrant_country ||= line.gsub(/Registrant Country:/,"") if line=~ /Registrant Country:/
				registrant_email ||= line.gsub(/Registrant Email:/,"") if line=~ /Registrant Email:/
				admin_email ||= line.gsub(/Admin Email:/,"") if line =~ /Admin Email:/
				name_server.push(line.gsub(/Name Server:/,"")) if(line =~ /^Name Server: /)
			}
			values << [s_entity.url, registrant_name, organization_name, registrant_state, 
				registrant_country, registrant_email, admin_email]
			logger.info "PARSEDSUCCESSFULLY :"
			s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
		}
		BvLib.write_file(file_name, keys, values)
	rescue => e
		BvLib.write_file(file_name, keys, values)
		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

	def self.article_details
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'article_title', 'time_published']
		values = []
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
				values << [s_entity.url, article_title, time_published]
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			else
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
		BvLib.write_file(file_name, keys, values)
	rescue => e
		BvLib.write_file(file_name, keys, values)
		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end
	
	def self.safebrowsing
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['urls']
		values = []
		scrap_entities = ScrapEntity.executed.safebrowsing
		scrap_entities.each { |s_entity|
			logger = s_entity.logger
			res = get_response(s_entity)
			data = JSON.parse(res.body)
			matches = data["matches"]
			if matches != nil
			matches.each { |entry|
				values << entry["threat"]["url"]
			}
			end
			s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
		}
		BvLib.write_file(file_name, keys, values)
	rescue => e
		BvLib.write_file(file_name, keys, values)
 		s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
		logger.error "PARSERFAILED : #{e.message}"
	end

end
