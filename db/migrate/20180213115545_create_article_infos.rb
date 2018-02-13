class CreateArticleInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :article_infos do |t|
      t.text :url
      t.string :status
      t.text :title
      t.text :date_published
      t.string :author
      t.string :tags

      t.timestamps
    end
  end
end
