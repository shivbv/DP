class CreateWebsites < ActiveRecord::Migration[5.0]
  def change
    create_table :websites do |t|
      t.references :advertisment_info, foreign_key: true
      t.string :url
      t.integer :type

      t.timestamps
    end
  end
end
