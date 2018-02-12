class Site < ApplicationRecord
	has_one :similar_web_info
	has_one :scan_back_link_info
	has_one :twitter_info
	has_one :gravatar_profile_info
	has_one :rest_api_info
	has_one :word_press_info
	def self.batch_create(urls)
		update_array = []
		urls_found = Site.where(:url => urls).collect { |site| site.url }
		urls_not_found = urls - urls_found if urls && urls_found 
		if urls_not_found
			urls_not_found.each { |url|
				data = "('#{url}', '#{Time.now.getutc}', '#{Time.now.getutc}')" 
				update_array << data
			}
		end
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO sites (url, created_at, updated_at)
					VALUES #{update_array.shift(4096).join(',')}")
		end
		Site.where(:url => urls)
	end
end

