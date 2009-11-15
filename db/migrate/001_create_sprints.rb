class CreateSprints < ActiveRecord::Migration
  def self.up
    create_table :sprints do |t|
      t.column :sprint_no, :integer
      t.column :project_id, :integer
      t.column :target, :text
      t.column :start_date, :date
      t.column :duration, :integer

    end
  end

  def self.down
    drop_table :sprints
  end
end
