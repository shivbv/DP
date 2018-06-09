class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.references :rest_api_info, foreign_key: true
      t.integer :user_id
      t.string :name
      t.string :website
      t.text :description
      t.string :social_account
      t.string :gravatar_url

      t.timestamps
    end
  end
end
