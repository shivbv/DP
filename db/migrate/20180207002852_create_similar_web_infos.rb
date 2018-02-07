class CreateSimilarWebInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :similar_web_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status
      t.integer :global_rank
      t.integer :traffic
      t.string :category
      t.text :topcategories
      t.text :description
      t.text :toptags

      t.timestamps
    end
  end
end
