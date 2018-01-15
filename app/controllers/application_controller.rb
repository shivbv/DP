class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
	#heroku config:set REDIS_PROVIDER=REDISTOGO_URL
end
