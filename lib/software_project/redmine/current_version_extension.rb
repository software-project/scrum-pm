module SoftwareProject
  module Redmine
    module VersionExtension
      def self.included(base)
        base.class_eval do
          unloadable
          has_many :user_stories, :class_name => 'UserStory', :foreign_key => 'version_id'
        end
      end
    end # CurrentVersionExtension
    
    module IssueExtension
      def self.included(base)
        base.class_eval do
          unloadable
          belongs_to :user_story, :class_name => 'UserStory', :foreign_key => 'user_story_id'
        end
      end
    end
  end # Redmine
end # ScrumAlliance