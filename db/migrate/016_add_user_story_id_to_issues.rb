class AddUserStoryIdToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :user_story_id, :integer

  end

  def self.down
    remove_column :issues, :user_story_id
  end
end
