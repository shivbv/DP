class User < ApplicationRecord
  belongs_to :rest_api_info
	
	def self.create(ra_info_id, user_id, name, website, description, social_account, gravatar_url)
		User.new(:rest_api_info_id => ra_info_id, :user_id => user_id, :name => name, :website => website, 
				:description => description, :social_account => social_account, :gravatar_url => gravatar_url).save
	end
end
