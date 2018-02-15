class Website < ApplicationRecord
  belongs_to :advertisment_info
	
	module Category
		ADVERT = 0
		COUPON = 1
		DEAL = 2
		GIVEAWAY = 3
		PODCAST = 4
		OFFER = 5
		DISCOUNT = 6
	end

	def self.create(ads_info_id, url, category)
		Website.new(:advertisment_info_id => ads_info_id, :url => url, :category => category).save
	end	

end
