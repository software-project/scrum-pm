class ReplaceSprintWithVersion < ActiveRecord::Migration
  def self.up
    remove_column :user_stories, :sprint_id
    add_column :user_stories, :version_id, :integer

  end

  def self.down
    remove_column :user_stories, :version_id
    add_column :user_stories, :sprint_id, :integer
  end
end