class RemoveSprintsAndTasks < ActiveRecord::Migration
  def self.up
    drop_table :tasks
    drop_table :tasks_users
    drop_table :sprints
    drop_table :statuses

  end

  def self.down
    create_table :sprints do |t|
      t.column :sprint_no, :integer
      t.column :project_id, :integer
      t.column :target, :text
      t.column :start_date, :date
      t.column :duration, :integer

    end

    create_table :statuses do |t|
      t.string :name

      t.timestamps
    end

    Status.create :name => "Pending"
    Status.create :name => "In Progress"
    Status.create :name => "Done"

    create_table :tasks do |t|
      t.string :name
      t.text :description
      t.integer :status_id
      t.integer :user_story_id

      t.timestamps
    end

    create_table :tasks_users, :id => false do |t|
      t.integer :task_id
      t.integer :user_id
    end
    add_index :tasks_users, :task_id
    add_index :tasks_users, :user_id

  end
end
