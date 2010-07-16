require 'redmine'
require 'dispatcher'
require 'form_helper_extensions'
require 'version_patch'
require 'issue_patch'
require 'gchart'

Dispatcher.to_prepare do
  Version.send( :include, VersionPatch )
  Issue.send( :include, IssuePatch)
end

Redmine::Plugin.register :redmine_sprints do
  name 'Redmine Scrum Sprints plugin'
  author 'Software Project- Marcin Jedras'
  description 'This is Redmine plugin for scrum software development'
  version '0.1.4.1'

  project_module :sprints do
    permission :view_sprints, {:sprints => [:index, :show]}
    permission :manage_sprints_and_user_stories, {:sprints => [:create, :new, :edit, :update, :assign_us, :assign_to_milestone, :destroy],
                                                  :user_stories => [:new, :create, :edit, :update, :destroy]}
    permission :manage_tasks, {:issue_sprints => [:new, :create, :status_change, :update_task, :status_delete]}
  end
  
  Redmine::MenuManager.map :project_menu do |menu|
    menu.push :dashboard, { :controller => 'sprints', :action => 'show', :id => :show }, :caption => :label_dashboard, :after => :activity, :param => :project_id
    menu.push :backlog, { :controller => 'sprints', :action => 'index' }, :caption => :label_backlog, :after => :activity, :param => :project_id
  end

 # Redmine::Activity.map do |activity|
 #   activity.register :tasks
 # end

end
