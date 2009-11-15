require_dependency 'issue'

module IssuePatch
  def self.included(base)
    unloadable
    
    base.class_eval do
      belongs_to :user_story, :class_name => 'UserStory', :foreign_key => 'user_story_id'
    end
  end
end
