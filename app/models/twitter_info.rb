class TwitterInfo < ApplicationRecord
	belongs_to :site
	
	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	def url
		self.site.url
	end
	
	def self.batch_create(sites)
		update_array = []
		sites_found = TwitterInfo.where(:site => sites).collect { |twitter_info| twitter_info.site}
		sites_not_found = sites - sites_found if sites && sites_found
		if sites_not_found
			sites_not_found.each { |site|
				data = "('#{site.id}', '#{Status::NOTEXECUTED}', '', '', '', '#{Time.now.getutc}', '#{Time.now.getutc}')"
				update_array << data
			}
		end
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO twitter_infos(site_id, status, user_website, 
					user_location, user_follower_count, created_at, updated_at) 
					VALUES #{update_array.shift(4096).join(',')}")
		end
		TwitterInfo.where(:site => sites)
	end

end
