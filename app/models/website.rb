class Website < ApplicationRecord
  belongs_to :advertisment_info
	
	module Type
		ADVERT = 0
		COUPON = 1
		DEAL = 2
		GIVEAWAY = 3
		PODCAST = 4
		OFFER = 5
		DISCOUNT = 6
	end

	def self.create(ads_info_id, url, type)
		debugger
		Website.new(:advertisment_info_id => ads_info_id, :url => url, :type => type).save
	end	

end
