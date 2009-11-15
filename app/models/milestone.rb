class Milestone < ActiveRecord::Base
  has_many :user_stories
  belongs_to :project

end
