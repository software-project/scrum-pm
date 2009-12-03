class AddProjectToMilestone < ActiveRecord::Migration
  def self.up
    add_column :milestones, :project_id, :integer

  end

  def self.down
    remove_column :milestones, :project_id
  end
end
