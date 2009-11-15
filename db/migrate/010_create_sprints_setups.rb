class CreateSprintsSetups < ActiveRecord::Migration
  def self.up
    create_table :sprints_setups do |t|

      t.column :language, :string
      t.column :path, :string

    end
  end

  def self.down
    drop_table :sprints_setups
  end
end
