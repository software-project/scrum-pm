class AddPriorityToUs < ActiveRecord::Migration

  def self.up
    add_column :user_stories, :priority, :integer
    add_column :user_stories, :us_number, :integer

  end

  def self.down
    remove_column :user_stories, :priority
    remove_column :user_stories, :us_number
  end
end
