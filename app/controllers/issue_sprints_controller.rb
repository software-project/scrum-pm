class IssueSprintsController < ApplicationController
  unloadable
  before_filter :find_project

  
  # Add a new issue
  # The new issue will be created from an existing one if copy_from parameter is given
  def new
    @issue = Issue.new
    @issue.copy_from(params[:copy_from]) if params[:copy_from]
    @issue.project = @project
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      flash.now[:error] = 'No tracker is associated to this project. Please check the Project settings.'
      render :nothing => true, :layout => true
      return
    end
    @issue.user_story = UserStory.find(params[:user_story_id])
    if params[:issue].is_a?(Hash)
      @issue.attributes = params[:issue]
      @issue.watcher_user_ids = params[:issue]['watcher_user_ids'] if User.current.allowed_to?(:add_issue_watchers, @project)
    end
    @issue.author = User.current

    default_status = IssueStatus.default
    unless default_status
      flash.now[:error] = 'No default issue status is defined. Please check your configuration (Go to "Administration -> Issue statuses").'
      render :nothing => true, :layout => true
      return
    end
    @issue.status = default_status
    @allowed_statuses = ([default_status] + default_status.find_new_statuses_allowed_to(User.current.role_for_project(@project), @issue.tracker)).uniq

    if request.get? || request.xhr?
      @issue.start_date ||= Date.today
    else
      requested_status = IssueStatus.find_by_id(params[:issue][:status_id])
      # Check that the user is allowed to apply the requested status
      @issue.status = (@allowed_statuses.include? requested_status) ? requested_status : default_status
      if @issue.save
        attach_files(@issue, params[:attachments])
        flash[:notice] = l(:notice_successful_create)
        Mailer.deliver_issue_add(@issue) if Setting.notified_events.include?('issue_added')
        redirect_to(params[:continue] ? { :action => 'new', :tracker_id => @issue.tracker } :
                                        { :action => 'show', :id => @issue })
        return
      end
    end
    @priorities = Enumeration::get_values('IPRI')
    render :partial => "issue_sprints/new"
  end

  def create
    @issue = Issue.new
    @issue.copy_from(params[:copy_from]) if params[:copy_from]
    @issue.project = @project
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      flash.now[:error] = 'No tracker is associated to this project. Please check the Project settings.'
      render :nothing => true, :layout => true
      return
    end
    if params[:issue].is_a?(Hash)
      @issue.attributes = params[:issue]
      @issue.watcher_user_ids = params[:issue]['watcher_user_ids'] if User.current.allowed_to?(:add_issue_watchers, @project)
    end
    @issue.author = User.current
    @issue.fixed_version_id = @issue.user_story.version_id

    default_status = IssueStatus.default
    unless default_status
      flash.now[:error] = 'No default issue status is defined. Please check your configuration (Go to "Administration -> Issue statuses").'
      render :nothing => true, :layout => true
      return
    end
    @issue.status = default_status
    @allowed_statuses = ([default_status] + default_status.find_new_statuses_allowed_to(User.current.role_for_project(@project), @issue.tracker)).uniq

    requested_status = IssueStatus.find_by_id(params[:issue][:status_id])
    # Check that the user is allowed to apply the requested status
    @issue.status = (@allowed_statuses.include? requested_status) ? requested_status : default_status
    status = done_ratio_to_status(@issue)
    if @issue.save
      attach_files(@issue, params[:attachments])
      flash[:notice] = l(:notice_successful_create)
      Mailer.deliver_issue_add(@issue) if Setting.notified_events.include?('issue_added')
      render :update do |p|
        p.insert_html :bottom, "tasks_#{status}_us_#{@issue.user_story_id}", :partial => "shared/task_view", :locals => {:task => @issue}
      end
    end
    @priorities = Enumeration::get_values('IPRI')
  end

  def status_change
    issue = Issue.find(params[:task_id])

    if !issue.nil? && (done_ratio_to_status(issue) != params[:status_id] || issue.user_story_id != params[:user_story_id])
      if done_ratio_to_status(issue) != params[:status_id]
        issue.done_ratio = status_to_done_ratio(params[:status_id])
      end
      issue.user_story_id = params[:user_story_id]
      issue.author = User.current
    end

    if issue.save
      render :update do |p|
#         p.replace_html("task_wrap_#{task.id}", "")
        p.insert_html :bottom, "tasks_#{params[:status_id]}_us_#{issue.user_story_id}", :partial => "shared/task_view", :locals => {:task => issue}
      end
    end

#    task = Task.find(params[:id])
#    unless task.nil?
##      if (task.status_id.to_s != params[:status_id].to_s || (!params[:user_story_id].nil? && params[:user_story_id].to_s != task.user_story_id.to_s ))
#        task.status_id = params[:status_id]
#        task.author = User.current
#        if !params[:user_story_id].nil? and params[:user_story_id].to_s != task.user_story_id.to_s and !UserStory.find(params[:user_story_id]).nil?
#          task.user_story_id = params[:user_story_id]
#        end
#        if task.save
#          log_task(task)
#          render :update do |p|
##           p.replace_html("task_wrap_#{task.id}", "")
#            p.insert_html :bottom, "tasks_#{task.status_id }_us_#{task.user_story_id}", :partial => "shared/task_view", :locals => {:task => task}
#          end
#        end
##      end
#    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def done_ratio_to_status(issue)
    case issue.done_ratio
    when 0
      "1"
    when 100
      "3"
    else
      "2"
    end
  end

  def status_to_done_ratio(status)
    case status
    when "1"
      0
    when "3"
      100
    else
      50
    end
  end

end