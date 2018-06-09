class CreateGravatarProfileInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :gravatar_profile_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status
      t.string :name
      t.string :about_user
      t.string :location
      t.string :phone_numbers
      t.string :emails
      t.string :social_accounts
      t.string :websites

      t.timestamps
    end
  end
end
