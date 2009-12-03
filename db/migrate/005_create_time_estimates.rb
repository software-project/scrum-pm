class CreateTimeEstimates < ActiveRecord::Migration
  def self.up
    create_table :time_estimates do |t|
      t.string :estimation
      t.float :value

      t.timestamps
    end
    TimeEstimate.create :estimation => "?", :value => 0
    TimeEstimate.create :estimation => "0", :value => 0
    TimeEstimate.create :estimation => "1/2", :value => 0.5
    TimeEstimate.create :estimation => "1", :value => 1
    TimeEstimate.create :estimation => "2", :value => 2
    TimeEstimate.create :estimation => "3", :value => 3
    TimeEstimate.create :estimation => "5", :value => 5
    TimeEstimate.create :estimation => "8", :value => 8
    TimeEstimate.create :estimation => "14", :value => 14
    TimeEstimate.create :estimation => "20", :value => 20
    TimeEstimate.create :estimation => "50", :value => 50
    TimeEstimate.create :estimation => "80", :value => 80
    TimeEstimate.create :estimation => "100", :value => 100
  end

  def self.down
    drop_table :time_estimates
  end
end
