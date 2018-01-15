task :Storedata => :environment do
	params = eval(ENV["params"]) || {:headers => {}, :parameters => [], :referer => nil}
	filename = ENV["filename"] || ""
	category = ENV["category"].to_i
	websites = BvLib.parse_file(filename)
	websites_ar = websites.each_slice(4).to_a
	debugger
	Resque.enqueue(Storedata, websites_ar[0], category, params)
	Resque.enqueue(Storedata, websites_ar[1], category, params)
	Resque.enqueue(Storedata, websites_ar[2], category, params)
	Resque.enqueue(Storedata, websites_ar[3], category, params)
end

