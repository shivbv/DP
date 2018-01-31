task :scraping => :environment do
	params = eval(ENV["params"] || {})
	filename = ENV["filename"] || ""
	#debugger
	websites = Read.file_read(filename)
	Base_url = "https://www.trafficestimate.com/"
	urls = []
	websites.each { |website|
		urls.push("#{Base_url}#{website}/")
	}
	ScrapEntity.batch_create(urls, params, ScrapEntity::Category::TRAFFICESTIMATE, ScrapEntity::Status::NOTEXECUTED)
	Executer.execute
	Parser.trafficestimate
end

