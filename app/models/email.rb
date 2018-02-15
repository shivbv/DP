class Email < ApplicationRecord
  belongs_to :website_info

	def self.create(web_info_id, email)
		Email.new(:website_info_id => web_info_id, :email => email).save
	end

end
