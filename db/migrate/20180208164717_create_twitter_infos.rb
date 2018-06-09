class CreateTwitterInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status
      t.string :user_website
      t.string :user_location
      t.integer :user_follower_count

      t.timestamps
    end
  end
end
