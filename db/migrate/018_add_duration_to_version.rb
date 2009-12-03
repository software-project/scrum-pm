class AddDurationToVersion < ActiveRecord::Migration
  def self.up
    add_column :versions, :duration, :integer

  end

  def self.down
    remove_column :versions, :duration
  end
end
