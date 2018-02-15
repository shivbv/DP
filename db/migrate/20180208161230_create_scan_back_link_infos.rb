class CreateScanBackLinkInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :scan_back_link_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status
      t.integer :da
      t.integer :pa

      t.timestamps
    end
  end
end
