task :Storedata => :environment do
	params = eval(ENV["params"]) || {:headers => {}, :parameters => [], :referer => nil}
	filename = ENV["filename"] || ""
	category = ENV["category"].to_i
end

