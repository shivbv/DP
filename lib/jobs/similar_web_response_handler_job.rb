class SimilarWebResponseHandlerJob
	def self.queue
		:responsehandler
	end

	def self.perform(task_id, swinfo_id, response_code)
		swinfo = SimilarWebInfo.find_by(:id => swinfo_id)
		if response_code == 200
			swinfo.status = SimilarWebInfo::Status::EXECUTED
		else
			swinfo.status = SimilarWebInfo::Status::EXECUTIONFAILED
		end
		task = Task.find_by(:id => task_id)
		task.update_attributes!(:executed_entries => task.executed_entries + 1)
		#SimilarWeb.parse(task_id) if task.executed_entries == task.total_entries
	end
