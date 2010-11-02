class AddRedirectionToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :redirect_to, :string

  end

  def self.down
    remove_column :issues, :redirect_to
  end
end