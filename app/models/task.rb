class Task < ApplicationRecord
	def self.create(category, inputfile, outputfile, total_entries)
		Task.new(:category => category, :inputfile => inputfile, :outputfile => outputfile, :total_entries => total_entries,
				:executed_entries => 0).save
	end
end

