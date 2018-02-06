class SimilarWebInfo < ApplicationRecord
  belongs_to :site

	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	def self.create_sw_infos(sites)
		update_array = []
		urls = sites.collect { |site| "https://api.similarweb.com/v1/SimilarWebAddon/#{site.url}/all" }
		for index in 0...urls.length
			swinfo = SimilarWebInfo.find_by(:site => sites[index])
			if swinfo == nil
				data = "('#{sites[index].id}', '#{urls[index]}', '#{Status::NOTEXECUTED}', '', '', '', '', '', 
					'', '#{Time.now.getutc}', '#{Time.now.getutc}' )"
				update_array << data
			end
		end
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO similar_web_infos(site_id, url, status, 
				globalrank, traffic, category, topcategories, description, toptags, created_at, updated_at)
						VALUES #{update_array.shift(4096).join(',')}")
		end
		SimilarWebInfo.where(:site => sites)
	end
end
