class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
      t.references :website_info, foreign_key: true
      t.string :email

      t.timestamps
    end
  end
end
