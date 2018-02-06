class CreateSimilarWebInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :similar_web_infos do |t|
      t.references :site, foreign_key: true
      t.string :url
      t.integer :status
      t.string :globalrank
      t.string :traffic
      t.string :category
      t.string :topcategories
      t.string :description
      t.string :toptags

      t.timestamps
    end
  end
end
