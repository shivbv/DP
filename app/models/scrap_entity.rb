class ScrapEntity < ApplicationRecord
	serialize :params, Hash
	scope :notexecuted, -> { where(:status => Status::NOTEXECUTED)}
	scope :executed, -> { where(:status => Status::EXECUTED)}
	scope :executionfailed, -> { where(:status => Status::EXECUTIONFAILED)}
	scope :parsed, -> { where(:status => Status::PARSED)}
	scope :parsingfailed, -> { where(:status => Status::PARSINGFAILED)}
	scope :similarweb, -> { where(:category => Category::SIMILARWEB)}
	scope :trafficestimate, -> { where(:category => Category::TRAFFICESTIMATE)}
	scope :scanbacklinks, -> { where(:category => Category::SCANBACKLINKS)}
	scope :twitter, -> { where(:category => Category::TWITTER)}
							
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
		File.open(filename, 'wb') { |file|
			file.write(content)
		}
	end

	def self.create(url, params, category, status = Status::NOTEXECUTED)
		ScrapEntity.new(:url => url, :params => params, :category => category, :status => status).save
	end

	def self.batch_create(urls, params, category, status = Status::NOTEXECUTED)
		update_array = []
		urls.each { |url|
			data = "('#{url}', '#{params.to_yaml}', #{category}, #{status}, '#{Time.now.getutc}', '#{Time.now.getutc}')"
			update_array << data
		}
		while !update_array.empty?
			ActiveRecord::Base.connection.execute("INSERT INTO scrap_entities (url, params, category, status, created_at, updated_at)
					VALUES #{update_array.shift(4096).join(',')}")
		end
	end
end
