class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.string :inputfile
      t.string :outputfile
      t.integer :total_entries
      t.integer :executed_entries

      t.timestamps
    end
  end
end
