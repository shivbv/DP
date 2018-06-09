class CreateRestApiInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :rest_api_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
