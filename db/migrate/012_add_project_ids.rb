class AddProjectIds < ActiveRecord::Migration

  def self.up
    add_column :documentations, :project_id, :integer
    add_column :sprints_setups, :project_id, :integer

  end

  def self.down
    remove_column :documentations, :project_id
    remove_column :sprints_setups, :project_id
  end
end
