class SimilarWebInfo < ApplicationRecord
	belongs_to :site
	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	def url
		"https://api.similarweb.com/v1/SimilarWebAddon/#{self.site.url}/all"
	end

	def self.batch_create(sites)
		update_array = []	
		sites_found = SimilarWebInfo.where(:site => sites).collect { |swinfo| swinfo.site}
		sites_not_found = sites - sites_found if sites && sites_found
		sites_not_found.each { |site|
			data = "('#{site.id}', '#{Status::NOTEXECUTED}', '', '', '', '', '', '', '#{Time.now.getutc}', 
					'#{Time.now.getutc}')"
			update_array << data
		}
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO similar_web_infos(site_id, status, 
					global_rank, traffic, category, topcategories, description, toptags, created_at, updated_at)
					VALUES #{update_array.shift(4096).join(',')}")
		end
		SimilarWebInfo.where(:site => sites)
	end
end
