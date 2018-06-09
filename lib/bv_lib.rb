require 'csv'
module BvLib
	def self.parse_urls_file(filename)
		websites = []
		File.open(filename).each { |website|
			websites.push(website.strip)
		}
		websites.uniq!
		websites
	end
end
