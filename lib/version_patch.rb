
require_dependency 'version'

module VersionPatch
  def self.included(base)
    base.extend(ClassMethods) 
    base.send(:include, InstanceMethods)
    
    unloadable
    base.class_eval do
      has_many :user_stories, :class_name => 'UserStory', :foreign_key => 'version_id'
    end
  end
  module ClassMethods
  
  end
  
  module InstanceMethods
    
  end
end

