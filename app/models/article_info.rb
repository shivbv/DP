class ArticleInfo < ApplicationRecord
	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	def self.batch_create(urls)
		update_array = []
		urls_found = ArticleInfo.where(:url => urls).collect { |article_info| article_info.url}
		urls_not_found = urls - urls_found 
		urls_not_found.each { |url|
			data = "('#{url}', '#{Status::NOTEXECUTED}', '', '', '', '','#{Time.now.getutc}', 
																								'#{Time.now.getutc}')"
			update_array << data
		}
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO article_infos(url, status, title
																						, date_published, Author, Tags, created_at, updated_at)	
																						VALUES #{update_array.shift(4096).join(',')}")
		end
		ArticleInfo.where(:url => urls)
	end
end
