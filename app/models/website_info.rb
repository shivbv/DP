class WebsiteInfo < ApplicationRecord
  belongs_to :site
	has_many :email

	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	def url
		"http://#{self.site.url}"
	end

	def self.batch_create(sites)
		update_array = []
		sites_found = WebsiteInfo.where(:site => sites).collect { |web_info| web_info.site}
		sites_not_found = sites - sites_found
		sites_not_found.each { |site|
			data = "('#{site.id}', '#{Status::NOTEXECUTED}', '#{Time.now.getutc}', '#{Time.now.getutc}')"
			update_array << data
		}
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO website_infos(site_id, status, created_at,
					updated_at) VALUES #{update_array.shift(4096).join(',')}")
		end
		WebsiteInfo.where(:site => sites)
	end

end
