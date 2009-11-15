require 'redmine'
require 'form_helper_extensions'
require 'dispatcher'
require 'version_patch'
require 'issue_patch'

Dispatcher.to_prepare do
  Version.send( :include, VersionPatch )
  Issue.send( :include, IssuePatch)
end


Redmine::Plugin.register :redmine_sprints do
  name 'Redmine Scrum Sprints plugin'
  author 'Software Project- Marcin Jedras'
  description 'This is Redmine plugin for scrum software development'
  version '0.0.2'

  permission :sprints, {:sprints => [:index, :new, :edit, :show]}, :public => true
  
  Redmine::MenuManager.map :project_menu do |menu|
    menu.push :dashboard, { :controller => 'sprints', :action => 'show', :id => :show }, :caption => :label_dashboard, :after => :activity, :param => :project_id
    menu.push :backlog, { :controller => 'sprints', :action => 'index' }, :caption => :label_backlog, :after => :activity, :param => :project_id
  end

 # Redmine::Activity.map do |activity|
 #   activity.register :tasks
 # end

end
