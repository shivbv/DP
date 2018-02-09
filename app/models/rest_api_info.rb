class RestApiInfo < ApplicationRecord
	belongs_to :site
	has_many :user

	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	def url
		"http://#{self.site.url}/wp-json/wp/v2/users"  
	end

	def self.batch_create(sites)
		update_array = []
		sites_found = RestApiInfo.where(:site => sites).collect { |ra_info| ra_info.site}
		sites_not_found = sites - sites_found if sites && sites_found
		sites_not_found.each { |site|
			data = "('#{site.id}', '#{Status::NOTEXECUTED}', '#{Time.now.getutc}', '#{Time.now.getutc}')"
			update_array << data
		}
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO rest_api_infos(site_id, status, created_at, updated_at)
					VALUES #{update_array.shift(4096).join(',')}")
		end
		RestApiInfo.where(:site => sites)
	end
end
