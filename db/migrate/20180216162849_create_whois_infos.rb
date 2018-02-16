class CreateWhoisInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :whois_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status
      t.string :registrant_name
      t.string :organization_name
      t.string :registrant_state
      t.string :registrant_country
      t.string :registrant_email
      t.string :admin_email

      t.timestamps
    end
  end
end
