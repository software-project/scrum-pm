class IssueSprintsController < IssuesController
  unloadable
  before_filter :find_project, :only => [:new, :create, :update_task, :status_change, :status_delete]
  helper SprintsHelper
  helper CustomFieldsHelper

  
  # Add a new issue
  # The new issue will be created from an existing one if copy_from parameter is given
  def new
    @issue.user_story_id = params[:user_story_id] unless params[:user_story_id].blank?
    @issue.fixed_version_id = @issue.user_story.version_id
    render :template => "issues/new", :layout => false
  end

  def update_task
    obj = Object.const_get(params[:model])
    value = nil
    value = obj.find(params[:value]) unless params[:value].blank?
    task = Issue.find(params[:task_id])
    eval "task.#{params[:field]}=#{value ? value.id : "nil"}"
    if task.save
      @issue_statuses = IssueStatus.find(:all)
      @project_users = User.find(:all, :joins => :members, :conditions => ["members.project_id = ?", @project.id])
      status = done_ratio_to_status(task)

      render :update do |page|
        page.replace "task_wrap_#{task.id}", ""
        page.insert_html :bottom, "tasks_#{ status }_us_#{task.user_story_id}", :partial => "shared/task_view",
                          :locals => {:task => task, :issue_statuses => @issue_statuses,
                          :project_users => @project_users}
      end
    else           
      render :update do |page|
        page.insert_html :top, "content", content_tag('div', t(:error_changing_status), :class => "error", :id => "errorExplanation")
      end
    end
  end

  def status_change
    issue = Issue.find(params[:task_id])

    if User.current.allowed_to?(:edit_issues, @project)
      journal = issue.init_journal(User.current, nil)

      if !issue.nil? && (done_ratio_to_status(issue) != params[:status_id] || issue.user_story_id != params[:user_story_id])
        if done_ratio_to_status(issue) != params[:status_id]
          issue.done_ratio = status_to_done_ratio(params[:status_id])
        end
        issue.status = issue_status(issue)
        issue.user_story_id = params[:user_story_id]
      end

      if issue.save                                     
        @issue_statuses = IssueStatus.find(:all)
        @project_users = User.find(:all, :joins => :members, :conditions => ["members.project_id = ?", @project.id])
        render :update do |p|
          p.replace "task_wrap_#{issue.id}", ""
          p.insert_html :bottom, "tasks_#{params[:status_id]}_us_#{issue.user_story_id}", :partial => "shared/task_view",
                        :locals => {:task => issue, :issue_statuses => @issue_statuses,
                        :project_users => @project_users}
        end
      else
        render :update do |page|
          page.insert_html :top, "content", content_tag('div', t(:error_changing_status), :class => "error", :id => "errorExplanation")
        end
      end
    end
  end

  def status_delete
    issue = Issue.find(params[:task_id])

    if !issue.user_story_id.nil? && User.current.allowed_to?(:edit_issues, @project)
      journal = issue.init_journal(User.current, nil)

      if !issue.nil? 
        issue.user_story_id = nil 
      end

      if issue.save                                     
      else
        render :update do |page|
          page.insert_html :top, "content", content_tag('div', t(:error_changing_status), :class => "error", :id => "errorExplanation")
        end
      end
    end
    render :text => nil
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def issue_status(issue)

    case issue.done_ratio
      when 0
        if issue.status_id.nil? || !issue.status_id.nil? && issue.status.position == 3
          IssueStatus.find_by_position(1)
        else
          issue.status
        end                   
      when 100
        IssueStatus.find_by_position(3)
      else
        IssueStatus.find_by_position(2)
    end
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
