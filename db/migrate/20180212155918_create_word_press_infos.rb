class CreateWordPressInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :word_press_infos do |t|
      t.references :site, foreign_key: true
      t.integer :status
      t.string :check

      t.timestamps
    end
  end
end
