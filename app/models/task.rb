class Task < ApplicationRecord
	def create(inputfile, outputfile, total_entries)
		Task.new(:inputfile => inputfile, :outputfile => outputfile, :total_entries => total_entries, 
						 :executed_entries => 0).save
	end
end
