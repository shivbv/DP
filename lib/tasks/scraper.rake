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

	task :scanbacklinks => :environment do
		URL = 'https://scanbacklinks.com/check-dapa'
		param = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		websites = BvLib.parse_file(filename)
		params = [] 
		websites.each { |website|
			hash = {:headers => param[:headers], :parameter => param[:parameter], :referer => param[:referer], :website => website,
								:action => '/check-dapa', :field_with => 'checkform-site' }
			params << hash
		}
		ScrapEntity.batch_create(URL, params, ScrapEntity::Category::SCANBACKLINKS, ScrapEntity::Status::NOTEXECUTED)
	end

	task :twitter => :environment do
		params = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		profiles = BvLib.parse_file(filename)
		urls = profiles.collect {|profile|
											"https://#{profile}"
		}
		ScrapEntity.batch_create(urls, params, ScrapEntity::Category::TWITTER, ScrapEntity::Status::NOTEXECUTED)
	end

	task :webhost => :environment do 
		URL = "https://www.webhostinghero.com/who-is-hosting/"
		param = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		websites = BvLib.parse_file(filename)
		params = []
		websites.each { |website|
			hash = {:headers => param[:headers], :parameter => param[:parameter], :referer => param[:referer] , :website => website,
							:action => 'https://www.webhostinghero.com/who-is-hosting/', :field_with => 'url'}
			params << hash
		}
		ScrapEntity.batch_create(URL, params, ScrapEntity::Category::WEBHOST, ScrapEntity::Status::NOTEXECUTED)
	end

	task :restapi => :environment do
		url_last = "wp-json/wp/v2/users"
		params = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		websites = BvLib.parse_file(filename)
		urls = websites.collect {|website|
			                      "https://#{website}/#{url_last}"
		}
		ScrapEntity.batch_create(urls, params, ScrapEntity::Category::RESTAPI, ScrapEntity::Status::NOTEXECUTED)
	end

	task :checkwp => :environment do
		params = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		websites = BvLib.parse_file(filename)
		urls = websites.collect {|website|
			                      "https://#{website}"
		}
		ScrapEntity.batch_create(urls, params, ScrapEntity::Category::CHECKWP, ScrapEntity::Status::NOTEXECUTED)
	end

	task :whois => :environment do
		params = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		urls = BvLib.parse_file(filename)
		ScrapEntity.batch_create(urls, params, ScrapEntity::Category::WHOIS, ScrapEntity::Status::NOTEXECUTED)
	end
		
	task :article_details => :environment do
		params = eval(ENV["params"]) || {:headers => {}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		article_urls = BvLib.parse_file(filename)
		ScrapEntity.batch_create(article_urls, params, ScrapEntity::Category::ARTICLE_DETAILS, ScrapEntity::Status::NOTEXECUTED)
	end

	task :safebrowsing => :environment do
		URL = "https://safebrowsing.googleapis.com/v4/threatMatches:find?key="
		param = eval(ENV["params"]) || {:headers => {'Content-Type'=> 'application/json'}, :parameter => [], :referer => nil}
		filename = ENV["filename"] || ""
		key = ENV["key"] || ""
		websites = BvLib.parse_file(filename)
		websites = websites.collect { |website| 
			{'url' => "http://www.#{website}/"}
		}
		params = []
		while !websites.empty?
			query =	{
								"client": {
									"clientId":      "test",
																	"clientVersion": "1.0.0"
			},
																															"threatInfo": {
									"threatTypes":      ["MALWARE", "SOCIAL_ENGINEERING","POTENTIALLY_HARMFUL_APPLICATION","UNWANTED_SOFTWARE"],
																	"platformTypes":    ["WINDOWS","ANY_PLATFORM","OSX","LINUX","ALL_PLATFORMS","CHROME","ANDROID","IOS"],
																												"threatEntryTypes": ["URL","IP_RANGE"],
																																										"threatEntries": websites.shift(500)
			}	
			}
			params << {:headers => param[:headers], :parameter => param[:parameter], :referer => param[:referer], 
				:query => query, :key => key }
		end
		ScrapEntity.batch_create(URL, params, ScrapEntity::Category::SAFEBROWSING, ScrapEntity::Status::NOTEXECUTED)
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
		Parser.trafficestimate if category == ScrapEntity::Category::TRAFFICESTIMATE
		Parser.scanbacklinks if category == ScrapEntity::Category::SCANBACKLINKS
		Parser.twitter if category == ScrapEntity::Category::TWITTER
		Parser.webhost if category == ScrapEntity::Category::WEBHOST
		Parser.restapi if category == ScrapEntity::Category::RESTAPI
		Parser.checkwp if category == ScrapEntity::Category::CHECKWP
		Parser.whois if category == ScrapEntity::Category::WHOIS
		Parser.article_details if category == ScrapEntity::Category::ARTICLE_DETAILS
		Parser.safebrowsing if category == ScrapEntity::Category::SAFEBROWSING
	end

end
