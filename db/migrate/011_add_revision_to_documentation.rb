class AddRevisionToDocumentation < ActiveRecord::Migration

  def self.up
    add_column :documentations, :revision, :integer

  end

  def self.down
    remove_column :documentations, :revision

  end
end
