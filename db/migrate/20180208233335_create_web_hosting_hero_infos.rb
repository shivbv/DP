class CreateWebHostingHeroInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :web_hosting_hero_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status
      t.string :webhost

      t.timestamps
    end
  end
end
