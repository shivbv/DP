namespace :scraping do

	task :similarweb => :environment do
		params = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		websites = BvLib.parse_file(filename)
		Base_url = "https://api.similarweb.com/v1/SimilarWebAddon/"
		urls = websites.collect { |url|
		"#{Base_url}#{url}/all"
		}
		ScrapEntity.batch_create(urls, params, ScrapEntity::Category::SIMILARWEB, ScrapEntity::Status::NOTEXECUTED)
		#Rake::Task["Executer"].invoke
		#Rake::Task["scraping:Parser"].invoke(ScrapEntity::Category::SIMILARWEB)
	end

	task :trafficestimate => :environment do
		params = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		websites = BvLib.parse_file(filename)
		Base_url = "https://www.trafficestimate.com/"
		urls = websites.collect { |url|
								"#{Base_url}#{url}"
		}
		ScrapEntity.batch_create(urls, params, ScrapEntity::Category::TRAFFICESTIMATE, ScrapEntity::Status::NOTEXECUTED)
	end

	task :Executer => :environment do
		entity_ids = ScrapEntity.notexecuted.ids
		ids_array = entity_ids.in_groups(4, false)
		Resque.enqueue(Executer, ids_array[0])
		Resque.enqueue(Executer, ids_array[1])
		Resque.enqueue(Executer, ids_array[2])
		Resque.enqueue(Executer, ids_array[3])
	end

	task :Parser => :environment do
		category = ENV['category'].to_i
		Parser.similarweb if category == ScrapEntity::Category::SIMILARWEB
	end

end
