class ScanBackLinkInfo < ApplicationRecord
	belongs_to :site

	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	def url
		'https://scanbacklinks.com/check-dapa'
	end

	def self.batch_create(sites)
		update_array = []
		sites_found = ScanBackLinkInfo.where(:site => sites).collect { |sbl_info| sbl_info.site}
		sites_not_found = sites - sites_found
		sites_not_found.each { |site|
			data = "('#{site.id}', '#{Status::NOTEXECUTED}', '', '', '#{Time.now.getutc}', '#{Time.now.getutc}')"
			update_array << data
		}
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO scan_back_link_infos(site_id, status, da, pa, 
				created_at, updated_at)	VALUES #{update_array.shift(4096).join(',')}")
		end
		ScanBackLinkInfo.where(:site => sites)
	end

end

