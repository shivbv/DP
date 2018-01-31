require 'csv'
module BvLib
	def self.parse_file(file_name)
		websites = []
		File.open(file_name).each { |website|
			websites.push(website.strip)
		}
		websites
	end

	def self.write_file(file_name, keys, values)
		CSV.open(file_name, 'w+') do |csv|
			csv << keys
			values.each { |value|
				csv << value
			}
		end
	end
end
