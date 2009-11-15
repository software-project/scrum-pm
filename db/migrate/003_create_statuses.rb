class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :name

      t.timestamps
    end
    
    Status.create :name => "Pending"
    Status.create :name => "In Progress"
    Status.create :name => "Done"
  end

  def self.down
    drop_table :statuses
  end
end
