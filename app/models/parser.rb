require 'csv'
class Parser
	def self.get_response(s_entity)
		mechanize = Mechanize.new
		res = mechanize.get("file:///#{s_entity.filename}")
	end

	def self.similarweb()
		file_name = ENV["filename"] || "/home/sumit/result/sumilarweb.csv"
		scrap_entities = ScrapEntity.executed.similarweb
		CSV.open(file_name, 'wb+') { |csv|
			csv << ['website', 'global_rank', 'estimated_traffic', 'category', 'topcategories', 'description', 'toptags']
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
					url = s_entity.url
					url.gsub!("https://api.similarweb.com/v1/SimilarWebAddon/","")
					csv << [url, global_rank, estimatted_traffic, category, 
						topcategories, description, toptags]
					s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
					logger.info "PARSEDSUCCESSFULLY :"
				rescue => e
					csv << [s_entity.url, 'NOTFOUND']
					s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
					logger.error "PARSINGFAILED : response is nil"
				end
			}
		}
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
		file_name = ENV["filename"] || "/home/sumit/result/da.csv"
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
		file_name = ENV["filename"] || "/home/sumit/result/whoisinfo4feb.csv"
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
				registrant_state.force_encoding('UTF-8') if registrant_state
				organization_name.force_encoding('UTF-8') if organization_name
				registrant_name.force_encoding('UTF-8') if registrant_name
				registrant_country.force_encoding('UTF-8') if registrant_country
				registrant_email.force_encoding('UTF-8') if registrant_email
				admin_email.force_encoding('UTF-8') if admin_email
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
						s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
						logger.info "PARSEDSUCCESSFULLY :"
					end
				rescue => e
					logger.error "PARSERFAILED : #{e.message}"
					s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				end
			}
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
		file_name = ENV["filename"] || "/home/sumit/result/jayesh344.csv"
		keys = ['dealpage_status', 'advertpage_status', 'couponpage_status', 'giveawaypage_status', 'podcastpage_status', 
				'offerpage', 'discountpage']
		scrap_entities = ScrapEntity.executed.advertcheck
		CSV.open(file_name, 'wb+') { |csv|
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				res.links.each { |link|
					dealpage = ""
					advertpage = ""
					couponpage = ""
					giveawaypage = ""
					podcastpage = ""
					offerpage = ""
					discountpage = ""
					dealpage = link.href if link.href =~ /deal/i
					advertpage = link.href if link.href =~ /advert?/i
					couponpage = link.href if link.href =~ /coupon/i
					giveawaypage = link.href if link.href =~ /giveaway/i
					podcastpage = link.href if link.href =~ /podcast/i
					offerpage = link.href if link.href =~ /offer/i
					discountpage = link.href if link.href =~ /discount/i
					csv << [s_entity.url, dealpage, advertpage, couponpage, giveawaypage, podcastpage , offerpage, discountpage] if (couponpage != "" || advertpage != "" || dealpage != "" || podcastpage != "" || giveawaypage != "" || offerpage != "" || discountpage != "")		
				}
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
		}
	end

	def self.extractemail
		file_name = ENV["filename"] || "/home/sumit/result/emailinfo4feb1.csv"
		keys = ['website', 'email']
		values = []
		scrap_entities = ScrapEntity.executed.extractemail
		scrap_entities.each { |s_entity|
			begin
				logger = s_entity.logger
				res = get_response(s_entity)
				emails = res.body.scan(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/).flatten
				if emails != []
					emails.uniq!
					emails.each { |email| values << [s_entity.url, email] }
				end
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
				logger.info "PARSEDSUCCESSFULLY :"
			rescue => e
				s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
				logger.error "PARSERFAILED : #{e.message}"
			end
		}
		BvLib.write_file(file_name, keys, values)
	end
	
	def self.gravatar
		file_name = ENV["filename"] || "/home/sumit/result/gravatar2.csv"
		scrap_entities = ScrapEntity.gravatar
		CSV.open(file_name, 'wb+') { |csv|
			csv << ['website', 'name', 'location', 'phone_no', 'aboutme']
			scrap_entities.each { |s_entity|
				begin
					logger = s_entity.logger
					if (s_entity.status == ScrapEntity::Status::EXECUTIONFAILED)
						csv << [s_entity.url, 'PROFILENOTFOUND']
					elsif (s_entity.status == ScrapEntity::Status::EXECUTED)
						res = get_response(s_entity)
						data = JSON.parse(res.body)
						entry = data['entry'][0]
						if entry != nil
							name = entry['displayName']
							aboutme = entry['aboutMe']
							location = entry['currentLocation']
							phonenumbers = entry['phoneNumbers']
							phonenumbers = phonenumbers.collect {|phonenumber| phonenumber['value'] } if phonenumbers != nil 
							emails = entry['emails']
							emails = emails.collect{|email| email['value'] } if emails != nil
							accounts = entry['accounts']
							accounts = accounts.collect {|account| account['url'] } if accounts != nil
							websites = entry['urls']
							websites = websites.collect{|website| website['value'] }
							result =  [s_entity.url, name, location, phonenumbers, aboutme] 
							emails.each {|email| result << email } if emails != nil
							accounts.each {|account| result << account } if accounts != nil
							websites.each {|website| website << website } if websites != nil
							csv << result
						end
						s_entity.update_attributes!(:status => ScrapEntity::Status::PARSED)
						logger.info "PARSEDSUCCESSFULLY :"
					end
				rescue => e
					csv << [s_entity.url, 'PARSINGERROR']
					s_entity.update_attributes!(:status => ScrapEntity::Status::PARSINGFAILED)
					logger.error "PARSINGFAILED : #{e.message}"
				end
			}
		}
	end
end
