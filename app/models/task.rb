class Task < ApplicationRecord
	def self.create(category, inputfile, outputfile, total_entries)
		task = Task.new(:category => category, :inputfile => inputfile, :outputfile => outputfile, :total_entries => total_entries,
				:executed_entries => 0)
		task.save
		task
	end

end

