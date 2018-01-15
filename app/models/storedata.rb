class Storedata
	def self.queue
		:store
	end

	def self.perform(websites, category, params)
		similarweb(websites, params) if category == ScrapEntity::Category::SIMILARWEB
		trafficestimate(websites, params) if category == ScrapEntity::Category::TRAFFICESTIMATE
	end

	def self.similarweb(websites, params)
		base_url = "https://api.similarweb.com/v1/SimilarWebAddon/"
		urls = websites.collect { |url|
					"#{base_url}#{url}/all"
		}

		ScrapEntity.batch_create(urls, params, ScrapEntity::Category::SIMILARWEB, ScrapEntity::Status::NOTEXECUTED)
	end

	def self.trafficestimate(websites, params)
		base_url = "https://www.trafficestimate.com/"
		urls = []
		website.each { |website|
			urls.push("#{base_url}#{website}")
		}
		ScrapEntity.batch_create(urls, params, ScrapEntity::Category::TRAFFICESTIMATE, ScrapEntity::Status::NOTEXECUTED)
		end
end
