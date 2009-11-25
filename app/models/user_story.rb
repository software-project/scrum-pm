class UserStory < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :sprint, :class_name => 'Version', :foreign_key => 'version_id'
  belongs_to :time_estimate
  belongs_to :milestone
  has_many :issues, :class_name => 'Issue', :foreign_key => 'user_story_id'
  has_many :diagrams

end
