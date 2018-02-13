class ArticleResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.create_logger(swinfo_id)
		logger = Logger.new("#{Rails.root.to_s}/log/article_responsehandler.log")
		identifier = "XXXX #{swinfo_id} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
													"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def self.parse(response)
		if response
			article_title = response.at('meta[property="og:title"]') ? response.at('meta[property="og:title"]')[:content].strip : "NF"
			if article_title == "NF"
				article_title = response.title != nil ? response.title.strip : "NF"
			end
			date_published = response.at('meta[property="article:published_time"]')? 
				response.at('meta[property="article:published_time"]')[:content]:"NF"
				author = response.at('meta[property="article:publisher"]')? 
				response.at('meta[property="article:publisher"]')[:content].strip: "NF"  					
			if author == "NF"
				author = response.at('meta[property="article:author"]')? response.at('meta[property="article:author"]')[:content].strip: "NF"					
			end
			return article_title, date_published, author, ""
		end
	end

	def self.perform(task_id, articleinfo_id, response_code, response_file)
		logger = create_logger(articleinfo_id)
		articleinfo = ArticleInfo.find(articleinfo_id)
		task = Task.find(task_id)
		if response_code == 200
			data = JSON.parse(File.read(response_file))
			puts article_title, date_published, author, tags = parse(data)
			articleinfo.update_attributes!(:status => ArticleInfo::Status::PARSED, :title => article_title, 
																:date_published => date_published, :author => author, :tags => tags)
		else
			articleinfo.update_attributes!(:status => ArticleInfo::Status::EXECUTIONFAILED)
		end
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		logger.info "SUCCESSFULLYPARSED"
	rescue => e
		articleinfo.update_attributes!(:status => ArticleInfo::Status::PARSINGFAILED)
		logger.error "PARSINGFAILED #{e.message}"
	end
end
