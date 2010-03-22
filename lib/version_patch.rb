
require_dependency 'version'

module VersionPatch
  def self.included(base)
    base.class_eval do
      unloadable
      
      has_many :user_stories, :class_name => 'UserStory', :foreign_key => 'version_id'
      validates_presence_of :effective_date
    end
  end
end
