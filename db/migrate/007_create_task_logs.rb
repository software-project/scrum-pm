class CreateTaskLogs < ActiveRecord::Migration
  def self.up
    create_table :task_logs do |t|
      t.integer :user_id
      t.integer :task_id
      t.integer :status_id
      t.integer :sprint_id

      t.timestamps
    end
  end

  def self.down
    drop_table :task_logs
  end
end
