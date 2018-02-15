class CreateAdvertismentInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :advertisment_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status
      t.string :website
      t.integer :type

      t.timestamps
    end
  end
end
