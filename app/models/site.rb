class Site < ApplicationRecord
	has_one :similar_web_info
	def self.create_site(urls)
		update_array = []
		urls.each { |url|
			site_id = Site.find_by(:url => url)
			if site_id == nil 
				data = "('#{url}', '#{Time.now.getutc}', '#{Time.now.getutc}')"
				update_array << data
			end
		}
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO sites (url, created_at, updated_at)
					VALUES #{update_array.shift(4096).join(',')}")
		end
		Site.where(:url => urls)
	end
end

