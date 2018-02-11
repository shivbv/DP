class WebHostingHeroInfo < ApplicationRecord
	belongs_to :site
	
	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	def url
		"https://www.webhostinghero.com/who-is-hosting/"
	end

	def get_response
		res ||= Mechanize.new.get(url)
	end

	def self.batch_create(sites)
		update_array = []
		sites_found = WebHostingHeroInfo.where(:site => sites).collect { |whh_info| whh_info.site}
		sites_not_found = sites - sites_found if sites && sites_found
		if sites_not_found
			sites_not_found.each { |site|
				data = "('#{site.id}', '#{Status::NOTEXECUTED}', '', '#{Time.now.getutc}', '#{Time.now.getutc}')"
				update_array << data
			}
		end
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO web_hosting_hero_infos(site_id, status, webhost, 
					created_at, updated_at) VALUES #{update_array.shift(4096).join(',')}")
		end
		WebHostingHeroInfo.where(:site => sites)
	end
end
