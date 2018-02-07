class Site < ApplicationRecord
	has_one :similar_web_info
	def self.batch_create(urls)
		update_array = []
		urls_found = Site.where(:url => urls).collect { |site| site.url }
		urls_notfound = urls - urls_found
		urls_notfound.each { |url|
			data = "('#{url}', '#{Time.now.getutc}', '#{Time.now.getutc}')" 
			update_array << data
		}
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO sites (url, created_at, updated_at)
					VALUES #{update_array.shift(4096).join(',')}")
		end
		Site.where(:url => urls)
	end
end

