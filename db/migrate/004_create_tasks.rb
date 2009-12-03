class CreateTasks < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :tasks
    drop_table :tasks_users
  end
end
