require 'csv'
module BvLib
	def self.parse_urls_file(filename)
		websites = []
		File.open(filename).each { |website|
			websites.push(website.strip)
		}
		websites.uniq!
	end

	def self.write_file(task_id)
		CSV.open(file_name, 'w+') do |csv|
			csv << keys
			values.each { |value|
				csv << value
			}
		end
	end
end
