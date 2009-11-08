class CreateFinanceProjects < ActiveRecord::Migration
  def self.up
    create_table :finance_projects do |t|
      t.string :name
      t.integer :business_unit_id
      t.integer :manager_unit_id

      t.timestamps
    end
  end

  def self.down
    drop_table :finance_projects
  end
end
