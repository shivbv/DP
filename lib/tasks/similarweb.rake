task :scraping => :environment do
	params = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
	filename = ENV["filename"] || ""
	websites = BvLib.parse_file(filename)
	Base_url = "https://api.similarweb.com/v1/SimilarWebAddon/"
	urls = websites.collect { |url|
		"#{Base_url}#{url}/all"
	}
	ScrapEntity.batch_create(urls, params, ScrapEntity::Category::SIMILARWEB, ScrapEntity::Status::NOTEXECUTED)
	Executer.execute
	Parser.similarweb
end
