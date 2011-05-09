ActionController::Routing::Routes.draw do |map|

  # Agile PM members
  map.with_options :controller => 'user_stories' do |user_stories|
    user_stories.with_options :conditions => {:method => :get} do |user_stories|
      user_stories.connect 'projects/:project_id/user_stories/new/:sprint_id', :action => 'new'
      user_stories.connect 'projects/:project_id/user_stories/new', :action => 'new'
      user_stories.connect 'projects/:project_id/user_stories', :action => 'index'
      user_stories.connect 'projects/:project_id/user_stories/:id', :action => 'show'
      user_stories.connect 'projects/:project_id/user_stories/:id/edit', :action => 'edit'
    end
    user_stories.with_options :conditions => {:method => :post} do |user_stories|
      user_stories.connect 'projects/:project_id/user_stories/:id/:action', :action => /create|update|destroy/
    end
  end

  map.with_options :controller => 'tasks' do |tasks|
    tasks.with_options :conditions => {:method => :get} do |tasks|
      tasks.connect 'projects/:project_id/tasks', :action => 'index'
      tasks.connect 'projects/:project_id/tasks/issues', :action => 'issues'
      tasks.connect 'projects/:project_id/tasks/new/:userstory_id', :action => 'new'
      tasks.connect 'projects/:project_id/tasks/:id', :action => 'show'
      tasks.connect 'projects/:project_id/tasks/:id/edit', :action => 'edit'
      tasks.connect 'projects/:project_id/tasks/:id/status_change/:status_id', :action => 'status_change'

    end
    tasks.with_options :conditions => {:method => :post} do |tasks|
      tasks.connect 'projects/:project_id/tasks', :action => 'new'
      tasks.connect 'projects/:project_id/tasks/issues', :action => 'issues'
      tasks.connect 'projects/:project_id/tasks/:task_id/status_change/:status_id/:user_story_id', :action => 'status_change'
      tasks.connect 'projects/:project_id/tasks/:task_id/status_change/:status_id', :action => 'status_change'
      tasks.connect 'projects/:project_id/tasks/:id/:action', :action => /update|destroy/
    end
  end

  map.with_options :controller => 'milestones' do |milestones|
    milestones.with_options :conditions => {:method => :get} do |milestones|
      milestones.connect 'projects/:project_id/milestones/new', :action => 'new'
      milestones.connect 'projects/:project_id/milestones/:id/edit', :action => 'edit'
    end
    milestones.with_options :conditions => {:method => :post} do |milestones|
      milestones.connect 'projects/:project_id/milestones/:id/:action', :action => /update|destroy/
    end
  end

  map.with_options :controller => 'sprints' do |sprints|
    sprints.with_options :conditions => {:method => :get} do |sprints|
      sprints.connect 'projects/:project_id/sprints', :action => 'index'
      sprints.connect 'projects/:project_id/sprints/graph_code', :action => 'graph_code'
      sprints.connect 'projects/:project_id/sprints/new', :action => 'new'
      sprints.connect 'projects/:project_id/sprints/:id', :action => 'show'
      sprints.connect 'projects/:project_id/sprints/:id/edit', :action => 'edit'
      sprints.connect 'projects/:project_id/sprints/:id/:task_id', :action => 'show'
    end
    sprints.with_options :conditions => {:method => :post} do |sprints|
      sprints.connect 'projects/:project_id/sprints/:sprint/:us/assign_us', :action => 'assign_us'
      sprints.connect 'projects/:project_id/sprints/:milestone/:us/assign_to_milestone', :action => 'assign_to_milestone'
      sprints.connect 'projects/:project_id/sprints/:id/:action', :action => /create|update|destroy/
    end
#    sprints.with_options :conditions => {:method => :post} do |sprints|
#      sprints.connect 'projects/:project_id/sprints', :action => "create"
#    end
    sprints.connect 'projects/:project_id/sprints/:id/svg_graph', :conditions => {:method => :post}
  end

    map.with_options :controller => 'diagrams' do |diagrams|
    diagrams.with_options :conditions => {:method => :get} do |diagrams|
#      diagrams.connect 'projects/:project_id/diagrams', :action => 'index'
      diagrams.connect 'projects/:project_id/diagrams/new/:userstory_id', :action => 'new'
#      diagrams.connect 'projects/:project_id/diagrams/:id', :action => 'show'
#      diagrams.connect 'projects/:project_id/diagrams/:id/edit', :action => 'edit'
    end
    diagrams.with_options :conditions => {:method => :post} do |diagrams|
      diagrams.connect 'projects/:project_id/diagrams', :action => 'create'
      diagrams.connect 'projects/:project_id/diagrams/:id/:action', :action => /destroy/#/update|destroy/
    end
  end

  map.with_options :controller => 'documentations' do |documentations|
    documentations.with_options :conditions => {:method => :get} do |documentations|
      documentations.connect 'projects/:project_id/documentations/:id/edit', :action => 'edit'
      documentations.connect 'projects/:project_id/documentations/show_api', :action => 'show_api'
      documentations.connect 'projects/:project_id/documentations/*path', :action => 'show_doc'
    end
    documentations.with_options :conditions => {:method => :post} do |documentations|
      documentations.connect 'projects/:project_id/documentations', :action => 'setup'
      documentations.connect 'projects/:project_id/documentations/update_repo', :action => 'update_repo'
      documentations.connect 'projects/:project_id/documentations/generate_documentation', :action => 'generate_documentation'
      documentations.connect 'projects/:project_id/documentations/:id/update', :action => 'update'
    end
  end

  map.with_options :controller => 'issue_sprints' do |issue_sprints|
    issue_sprints.with_options :conditions => {:method => :post} do |tasks|
      issue_sprints.connect 'projects/:project_id/issue_sprints/new/:user_story_id/new', :action => 'new'
      issue_sprints.connect 'projects/:project_id/issue_sprints/:task_id/status_change/:status_id/:user_story_id', :action => 'status_change'
      issue_sprints.connect 'projects/:project_id/issue_sprints/:task_id/update_task/:field/:model/:value', :action => 'update_task'
    end
    issue_sprints.with_options :conditions => {:method => :get} do |tasks|
      issue_sprints.connect 'projects/:project_id/issue_sprints/new/:user_story_id', :controller => 'issue_sprints', :action => 'new'
    end
  end

end

