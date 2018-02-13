namespace :articles do
	task :fetch => :environment do
		debugger
		inputfile = ENV['inputfile']
		outputfile = ENV['outputfile']
		urls = BvLib.parse_urls_file(inputfile)
		article_infos = ArticleInfo.batch_create(urls)
		task = Task.create('ARTICLE_DETAILS', inputfile, outputfile, urls.length)
		puts task_id = task.id
		article_infos.each { |article_info|
			$article_queue << [article_info,task.id]
		}
		ThrottlerJob.new.perform_article_details()
	end

	task :output => :environment do
		task_id = ENV['task_id'].to_i
		task = Task.find(task_id)
		inputfile = task.inputfile
		urls = BvLib.parse_urls_file(inputfile)
		article_infos = ArticleInfo.where(:url => urls)
		article_infos.each { |article_info|
			puts [article_info.title, article_info.date_published, article_info.author , article_info.tags]
		}
	end
end

