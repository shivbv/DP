class Parser
	def self.get_response(s_entity)
		mechanize = Mechanize.new
		res = mechanize.get("file:///#{s_entity.filename}")
	end

	def self.similarweb()
		file_name = ENV["filename"] || "/home/check.csv"
		scrap_entities = ScrapEntity.executed.similarweb
		keys = ['website', 'global_rank', 'estimated_traffic', 'category', 'topcategories', 'description', 'toptags']
		values = []
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				data = JSON.parse(res.body)
				global_rank = data["GlobalRank"]["Rank"]
				estimatted_traffic = data["Engagments"]["Visits"]
				title = data["Title"]
				category = data["Category"]
				topcategories = data["TopCategoriesAndFills"].collect { |category| category["Category"] }.join(", ")
				toptags = data["TopTagsAndStrength"].collect { |tag| tag["Tag"] }.join(", ")
				description = data["Description"]
				values << [s_entity.params['website'], global_rank, estimatted_traffic, category, 
					topcategories, description, toptags]
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
		BvLib.write_file(file_name, keys, values)
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
		keys = ['url', 'website', 'DA', 'PA']
		values = []
		scrap_entities = ScrapEntity.executed.scanbacklinks
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				da = res.search('.result-content span')[1].text
				pa = res.search('.result-content span')[2].text
				values << [s_entity.url, s_entity.params[:website], da, pa]
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
				list1 = res.search("ul.detail li")[5]
				list2 = res.search("ul.detail li")[6]
				webhost = ""
				webhost = list1.text if (list1 != nil && list1.text =~ /ISP:/) || (list2 != nil && list2.text =~ /ISP:/)
				webhost.gsub!("ISP:","")
				values << [s_entity.url, webhost]
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
			begin
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
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.whois
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'registrant_name', 'organization_name', 'registrant_state',
						'registrant_country', 'registrant_email', 'admin_email']
		values = []
		scrap_entities = ScrapEntity.executed.whois
		scrap_entities.each { |s_entity|
			begin
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
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end	
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.article_details
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['url', 'article_title', 'time_published']
		values = []
		scrap_entities = ScrapEntity.executed.article_details
		scrap_entities.each { |s_entity|
			begin	
				logger = s_entity.logger
				res = get_response(s_entity)
				article_title = res.at('meta[property="og:title"]') ? res.at('meta[property="og:title"]')[:content].strip : "NF"
				if article_title == "NF"
					article_title = res.title != nil ? res.title.strip : "NF"
				end
				time_published = res.at('meta[property="article:published_time"]')?res.at('meta[property="article:published_time"]')[:content]:"NF"
				values << [s_entity.url, article_title, time_published]
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.safebrowsing
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['urls']
		values = []
		scrap_entities = ScrapEntity.executed.safebrowsing
		scrap_entities.each { |s_entity|
			begin
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
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSINGFAILED : response is nil"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.wpplugins
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ["Plugin_name", "Plugin_link", "Plugin_rating", "Plugin_author", "Plugin_active_installs",
			"Plugins_last_update"]
			values = []
			scrap_entities = ScrapEntity.executed.wpplugins
			scrap_entities.each { |s_entity|
				begin
					logger = s_entity.logger
					res = get_response(s_entity)
					for plugin_no in 0..13
						plugin = res.search('article')[plugin_no]
						plugin_link = plugin.search('a')[0]['href']
						plugin_name = plugin.search('a')[1].text
						plugin_rating = 0.0
						for spantag in 0..4
							rating_string = plugin.search('span')[spantag]['class']
							if(rating_string == 'dashicons dashicons-star-filled')
								plugin_rating += 1
							elsif (rating_string == 'dashicons dashicons-star-half')
								plugin_rating += 0.5 
							else
								break
							end  
						end
						footer = res.search('footer span')
						plugin_author = footer[0].text.strip
						active_install = footer[1].text.strip
						last_updated = footer[3].text.strip
						values << [plugin_name, plugin_link, plugin_rating, plugin_author, active_install, last_updated]
						s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
						logger.info "PARSEDSUCCESSFULLY :"
					end
				rescue => e
					logger.error "PARSERFAILED : #{e.message}"
					s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				end
			}
		BvLib.write_file(file_name, keys, values)
	end

	def self.whosip
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['URL', 'iprange', 'webhost']
		values = []
		scrap_entities = ScrapEntity.executed.whosip
		scrap_entities.each { |s_entity|
			begin
			logger = s_entity.logger
			res = get_response(s_entity)
			webhost = nil
			iprange = nil
			res.body.each_line { |line|
			webhost ||= line.gsub("OrgName:","").strip if line =~ /OrgName:/ || line =~ /org-name:/
			iprange ||= line.gsub("NetRange:","").strip if line =~ /NetRange:/ || line =~ /net-range:/ || line =~ /inetnum:/
			}
			values << [s_entity.url, iprange, webhost]
			s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
			logger.info "PARSEDSUCCESSFULLY :"
			rescue => e
			s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
			logger.error "PARSERFAILED : #{e.message}"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.extractplugins
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['website', 'Plugins']
		values = []
		scrap_entities = ScrapEntity.executed.extractplugins
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				values << [s_entity.params[:website], s_entity.params[:plugin]] if res != nil && res.body.scan("404").length == 0
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

	def self.advertcheck
		file_name = ENV["filename"] || "/home/check.csv"
		keys = ['website', 'dealpage_status', 'advertpage_status', 'couponpage_status']
		values = []
		scrap_entities = ScrapEntity.executed.advertcheck
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				dealpage_status = ""
				advertpage_status = ""
				couponpage_status = ""
				res.body.each_line { |line|
					dealpage_status = "yes"  if line =~ /deals?/i
					advertpage_status = "yes" if line =~ /advert/i
					couponpage_status = "yes" if line =~ /coupon/i
				}
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
				values << [s_entity.url, dealpage_status, advertpage_status, couponpage_status]
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end

end
