require 'resque/tasks'
task :Executer => :environment do
	entity_ids = ScrapEntity.notexecuted.ids
	ids_array = entity_ids.each_slice(4).to_a
	Resque.enqueue(Executer, ids_array[0])
	Resque.enqueue(Executer, ids_array[1])
	Resque.enqueue(Executer, ids_array[2])
	Resque.enqueue(Executer, ids_array[3])
end
