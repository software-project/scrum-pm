class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.column :target, :string
      t.column :deadline, :date
    end
    add_column :user_stories, :milestone_id, :integer
  end

  def self.down
    drop_table :milestones
    remove_column :user_stories, :milestone_id
  end
end
