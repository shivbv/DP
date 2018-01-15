module BvLib
	def self.parse_file(file_name)
		file = File.open(file_name).read
		websites = []
		file.each_line { |website|
			websites.push(website.strip)
		}
		websites

	end
end

