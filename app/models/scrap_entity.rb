class ScrapEntity < ApplicationRecord
	serialize :params, Hash
	scope :notexecuted, -> { where(:status => Status::NOTEXECUTED)}
	scope :executed, -> { where(:status => Status::EXECUTED)}
	scope :parsed, -> { where(:status => Status::PARSED)}
	scope :similarweb, -> { where(:category => Category::SIMILARWEB)}
	scope :trafficestimate, -> { where(:category => Category::TRAFFICESTIMATE)}
	scope :scanbacklinks, -> { where(:category => Category::SCANBACKLINKS)}
	scope :twitter, -> { where(:category => Category::TWITTER)}
	scope :webhost, -> { where(:category => Category::WEBHOST)}
	scope :restapi, -> { where(:category => Category::RESTAPI)}
	scope :checkwp, -> { where(:category => Category::CHECKWP)}
	scope :whois, -> { where(:category => Category::WHOIS)}
  scope :article_details, -> { where(:category => Category::ARTICLE_DETAILS)}
	scope :safebrowsing, -> { where(:category => Category::SAFEBROWSING)}
	scope :wpplugins, -> { where(:category => Category::WPPLUGINS)}
	scope :whosip, -> { where(:category => Category::WHOSIP)}
	scope :extractplugins, -> { where(:category => Category::EXTRACTPLUGINS)}
	scope :advertcheck, -> { where(:category => Category::ADVERTCHECK)}
	
	module Status
		NOTEXECUTED = 0
		EXECUTED = 1
		EXECUTIONFAILED = 2
		PARSED = 3
		PARSINGFAILED = 4
	end

	module Category
		SIMILARWEB = 1
		TRAFFICESTIMATE = 2
		SCANBACKLINKS = 3
		TWITTER = 4
		WEBHOST = 5
		ARTICLE_DETAILS = 6
		RESTAPI = 7
		CHECKWP = 8
		SAFEBROWSING = 9
		WHOIS = 10
		WPPLUGINS = 11
		WHOSIP = 12
		EXTRACTPLUGINS = 13
		ADVERTCHECK = 14
	end


	def logger
		logger = Logger.new("#{Rails.root.to_s}/log/logfile.log")
		identifier = "XXXX #{self.url} ===="
		logger.formatter = proc { |severity, datetime, progname, msg|
															"#{severity} #{datetime} #{identifier} #{msg}\n"
		}
		logger
	end

	def filename
		"#{Rails.root.to_s}/app/scrap_data/#{self.id}.html"
	end

	def	file_write(content)
		File.open(filename, 'ab+') { |file|
			file.write(content)
		}
	end

	def self.create(url, params, category, status = Status::NOTEXECUTED)
		ScrapEntity.new(:url => url, :params => params, :category => category, :status => status).save
	end

	def self.batch_create(urls, params, category, status = Status::NOTEXECUTED)
		update_array = []
		if urls.is_a?(Array) && params.is_a?(Array)
			for index in 0...urls.size
				data = "('#{urls[index]}', '#{params[index].to_yaml}', #{category}, #{status}, '#{Time.now.getutc}', '#{Time.now.getutc}')"
				update_array << data
			end
		elsif params.is_a?(Array)
			params.each { |param|
				data = "('#{urls}', '#{param.to_yaml}', #{category}, #{status}, '#{Time.now.getutc}', '#{Time.now.getutc}')"
				update_array << data
			}
		else
			urls.each { |url|
				data = "('#{url}', '#{params.to_yaml}', #{category}, #{status}, '#{Time.now.getutc}', '#{Time.now.getutc}')"
				update_array << data
			}
		end
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO scrap_entities (url, params, category, status, created_at, updated_at)
					VALUES #{update_array.shift(4096).join(',')}")
		end
	end

end
