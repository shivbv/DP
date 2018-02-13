class ThrottlerJob < ApplicationJob
	queue_as :default

	def perform_sw()
		while $sw_queue.length != 0
			sw_count = 0	
			while sw_count < 5
				temp_array = $sw_queue.pop
				swinfo = temp_array[0]
				task_id = temp_array[1]
				Resque.enqueue(WebRequestJob, 'GET', swinfo.url, {}, {'action' => 'SimilarWebResponseHandlerJob',
									'task_id' => task_id, 'id' => swinfo.id })
				sw_count += 1
				puts sw_count
			end
			sleep(10)
		end
	end

	def perform_twitter()
		while $twitter_queue.length != 0
			count = 0  
			while count < 10
				temp_array = $twitter_queue.pop  
				twitter_info = temp_array[0]
				task_id = temp_array[1]
				Resque.enqueue(WebRequestJob, 'GET', twitter_info.url, {}, {'action' => 'TwitterResponseHandlerJob',
																														 'task_id' => task_id, 'id' => twitter_info.id })
				count += 1
				puts count
			end
			sleep(20)
		end
	end
end
