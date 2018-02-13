namespace :similar_web do
	task :fetch => :environment do
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)	
		sites = Site.batch_create(urls)
		swinfos = SimilarWebInfo.batch_create(sites)
		task = Task.create('SIMILARWEB', inputfile, outputfile, urls.length)
		puts [task.id, 'SimilarWeb']
		swinfos.each { |swinfo|
	    $sw_queue << [swinfo,task.id]
		}
		ThrottlerJob.new.perform_sw()
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		sites = Site.where(:url => urls)
		swinfos = SimilarWebInfo.where(:site => sites)
		swinfos.each { |swinfo|
			puts [swinfo.global_rank, swinfo.traffic, swinfo.category, swinfo.topcategories, swinfo.description,
					swinfo.toptags]
		}	
	end
end
