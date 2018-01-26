class CreateScrapEntities < ActiveRecord::Migration[5.0]
  def change
    create_table :scrap_entities do |t|
      t.string :url
      t.text :params
      t.integer :category
      t.integer :status

      t.timestamps
    end
  end
end
