class CreateSqlViews < ActiveRecord::Migration
  def self.up
    create_table :sql_views do |t|
      t.string :name
      t.integer :creator
      t.text :sql

      t.timestamps
    end
  end

  def self.down
    drop_table :sql_views
  end
end
