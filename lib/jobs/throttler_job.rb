class ThrottlerJob

	def perform
		keys_array = QUEUE_NO_RATE_LIMIT.keys
		req_count = 1
		keys_array.each{ |key|
			if QUEUE_NO_RATE_LIMIT.get(key) != "Successful"
				args_array = JSON.parse(QUEUE_NO_RATE_LIMIT.get(key))
				type = args_array[0]
				url = args_array[1]
				params = args_array[2]
				event = args_array[3]
				Resque.enqueue(WebRequestJob, type, url, params, event)
				QUEUE_NO_RATE_LIMIT.set(key,"Successful")
				req_count += 1
			end
		}
	end

	def perform_per_two_min
		keys_array = QUEUE_TWO_MINUTE.keys
		req_count = 1
		keys_array.each{ |key|
			if QUEUE_TWO_MINUTE.get(key) != "Successful"
				if req_count % 20 != 0
					args_array = JSON.parse(QUEUE_TWO_MINUTE.get(key))
					type = args_array[0]
					url = args_array[1]
					params = args_array[2]
					event = args_array[3]
					Resque.enqueue(WebRequestJob, type, url, params, event)
					QUEUE_TWO_MINUTE.set(key,"Successful")
					req_count += 1
				else
					req_count += 1
					sleep(30)
				end
			end
		}
	end

	def perform_per_minute
		keys_array = QUEUE_PER_MINUTE.keys
		req_count = 1
		keys_array.each{ |key|
			if QUEUE_PER_MINUTE.get(key) != "Successful"
				if req_count % 20 != 0
					args_array = JSON.parse(QUEUE_PER_MINUTE.get(key))
					type = args_array[0]
					url = args_array[1]
					params = args_array[2]
					event = args_array[3]
					Resque.enqueue(WebRequestJob, type, url, params, event)
					QUEUE_PER_MINUTE.set(key, "Successful")
					req_count += 1
				else
					req_count += 1
					sleep(60)
				end
			end
		}
	end
end

