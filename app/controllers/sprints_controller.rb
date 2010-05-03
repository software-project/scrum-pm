class SprintsController < ApplicationController
  unloadable
  menu_item :backlog, :only => [:index]
  menu_item :dashboard, :only => [:show]

  before_filter :find_project, :authorize
  before_filter :find_sprint, :except => ["assign_us", 'new', 'create', 'index']
  before_filter :burndown, :only => [:index, :show]
  
  
#  helper TasksHelper
  helper CustomFieldsHelper
  helper SprintsHelper
  include SprintsHelper

  # GET /sprints
  # GET /sprints.xml
  def index
    @sprints = Version.find_all_by_project_id(@project.id, :order => 'effective_date DESC')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sprints }
    end
  end

  # GET /sprints/1
  # GET /sprints/1.xml
  def show
    unless @sprint.nil?
      @unassigned_tasks = Issue.find(:all, :joins => :status,
             :conditions => ["issue_statuses.is_closed = ? AND user_story_id IS NULL AND (fixed_version_id = ? OR project_id = ?)", false, @sprint.id, @project.id ])
      @issue_statuses = IssueStatus.find(:all)
      @project_users = User.find(:all, :joins => :members, :conditions => ["members.project_id = ?", @project.id])

      if defined? @sprint
        @data = load_sprint_stats(@sprint,[])
      end

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @sprint }
      end
    else
      redirect_to(:back)
    end

  end

#  # GET /sprints/new
#  # GET /sprints/new.xml
  def new
  	@sprint = @project.versions.build(params[:version])
    sprints = Version.find(:all, :conditions => ["project_id = ?",@project.id], :order => 'effective_date DESC')
    if sprints.size > 0
      @sprint.name = "Sprint " + (sprints.size + 1).to_s
      @sprint.effective_date = sprints.first.effective_date.advance(:days => 14)
    else
      @sprint.name = "Sprint 1"
      tmp_date = Time.now.advance(:days => 14)
      @sprint.effective_date = Date.new(tmp_date.year, tmp_date.month, tmp_date.day)
    end
    render :partial => "sprints/new"
  end
#
#  # GET /sprints/1/edit
  def edit
    @sprint = Version.find(params[:id])
    render :partial => "sprints/edit"
  end
#
#  # POST /sprints
#  # POST /sprints.xml
  def create
  	@sprint = @project.versions.build(params[:sprint])
    if @sprint.save
      render :update do |p|
        p.insert_html :top, 'sprints_fieldset_main', :partial => "sprints/sprint", :locals => {:sprint => @sprint}
        p["sprint_frame_cont_#{@sprint.id}"].visual_effect :blind_down, :duration => 1
      end
    else
      render :update do |page|
        page.insert_html :top, "content", content_tag('div', t(:error_while_adding_sprint), :class => "error", :id => "errorExplanation")
      end
    end
  end

  # PUT /sprints/1
  # PUT /sprints/1.xml
  def update

    render :update do |p|
      if @sprint.update_attributes(params[:sprint])
        data = load_sprint_stats(@sprint, [])
        p.replace_html "sprint_name_#{@sprint.id}", "#{@sprint.name}"
        p.replace_html "sprint_percent_done_#{@sprint.id}", :partial => "shared/percent_done", :locals => {:data => data}
        p.replace_html "sprint_dates_and_points_#{@sprint.id}", :partial => "sprints/sprint_dates_and_points", :locals => {:data => data, :sprint => @sprint}
        p.replace_html "sprint_target_#{@sprint.id}", l('sprint_description')+":" + @sprint.description
#        p.insert_html :top, "sprint_frame_cont_#{@sprint.id}", :partial => "sprints/sprint", :locals => {:sprint => @sprint}
        p["sprint_frame_cont_#{@sprint.id}"].visual_effect :highlight, :duration => 1
      end
    end
  end
#
#  # DELETE /sprints/1
#  # DELETE /sprints/1.xml
  def destroy
    sprint_id = @sprint.id
    @sprint.destroy
    render :update do |p|
      p["sprint_frame_cont_#{sprint_id}"].visual_effect :blind_up, :duration => 1
    end
  end

  def assign_us
    ver = nil
    us = UserStory.find(params[:us])
    sprint = nil
    sprint = Version.find(us.version_id) unless us.version_id.nil?
    if !params[:sprint].nil? && params[:sprint].to_s != "0"
      ver = Version.find(params[:sprint])
      ver.user_stories << [us]
      ver.save
    else
      us.sprint = nil
    end
    assign_to(us, params)
    
    if us.save
      render :update do |p|
        if params[:sprint].to_s != "0"
          p.insert_html :bottom, "sprint_"+us.version_id.to_s, :partial => "user_stories/sprint_item", :locals => {:user_story => us, :count => ver.user_stories.size}
          p.insert_html :bottom, "sprint_0", '<tr id="no_US_0"><td class="no_US" id="sprint_0_empty" colspan="5"><p>'+l('add_user_stories_are_assign')+'</p></td></tr>' if sprint.nil? && UserStory.find(:all, :conditions => ["version_id is null and project_id = ?",@project.id], :order => "priority ASC").size == 0
          p.insert_html :bottom, "sprint_"+sprint.id.to_s, "<tr id=\"no_US_#{sprint.id.to_s}\"><td colspan=\"4\" class=\"no_US\">#{l('drag_user_story_here_to_assign_it_to_sprint')}</td></tr>" if !sprint.nil? && sprint.user_stories.size == 0
          p.replace "no_US_"+ver.id.to_s, "" if ver.user_stories.size == 1
        else
          p.insert_html :bottom, "sprint_0", :partial => "user_stories/backlog_item", :locals => {:user_story => us, :count => UserStory.find(:all, :conditions => ["version_id is null and project_id = ?",@project.id]).size}
          p.insert_html :bottom, "sprint_"+sprint.id.to_s, "<tr id=\"no_US_#{sprint.id.to_s}\"><td colspan=\"4\" class=\"no_US\">#{l('drag_user_story_here_to_assign_it_to_sprint')}</td></tr>" if !sprint.nil? && sprint.user_stories.size == 0
          p.replace "no_US_0", "" if !sprint.nil? && UserStory.find(:all, :conditions => ["version_id is null and project_id = ?",@project.id], :order => "priority ASC").size == 1
        end
      end
    end
  end

  def assign_to_milestone
    us = UserStory.find(params[:us])
    milestone = Milestone.find(params[:milestone])
    unless us.milestone.nil?
      past_milestone = us.milestone
    end
    us.milestone = milestone

    if us.save
      render :update do |p|
        unless past_milestone.nil?
          p.replace "tab_milestone_#{us.id}", ""
          p.insert_html :bottom, "milestone_#{past_milestone.id}", "<tr id=\"no_milestone_#{past_milestone.id}\"><td colspan=\"6\" class=\"no_US\">#{l('drag_user_story_here_to_assign_it_to_milestone')}</td></tr>" if past_milestone.user_stories.size == 0
        end
        p.insert_html :bottom, "milestone_" + milestone.id.to_s, :partial => "user_stories/milestone_item", :locals => {:user_story => us, :count => milestone.user_stories.size}
        p.replace "no_milestone_"+milestone.id.to_s, "" if milestone.user_stories.size == 1
      end
    else

      redirect_to("/projects/#{@project.identifier}/sprints/")
    end   
  end

  private

  def validate_time_entry(time_entry, issue)
    errors.add :hours, :activerecord_error_invalid if time_entry.hours && (time_entry.hours < 0 || time_entry.hours >= 1000)
    errors.add :project_id, :activerecord_error_invalid if time_entry.project.nil?
    errors.add :issue_id, :activerecord_error_invalid if (time_entry.issue_id && !issue) || (issue && project!=issue.project)
  end

#  TODO przepisać na issues z tasków
  def us_points_per_day(sprint, tasklogs, date)
    tmp_tl = tasklogs.find_all{|tl| tl.created_at <= date}

    all_points = 0;

    for us in sprint.user_stories
      if us.created_at <= date
        task_points = 0;
        for task in us.issues
          tl_for_task = tmp_tl.find_all{|t| t.task_id == task.id}
          if !tl_for_task.nil? && tl_for_task.size > 0
            task_points += tl_for_task.last.status_id == 3 ? 1:0
          end
        end
        all_points += us.time_estimate.value unless task_points == us.issues.size
      end
    end

    all_points
  end

  def find_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def find_sprint
    if params[:sprint] && params[:sprint][:id]
      @sprint = Version.find(params[:sprint][:id])
    else
      if params[:id] && params[:id] != "show"
        @sprint = Version.find(params[:id])
      else
        @sprint = find_current_sprint
      end
    end
  end

  def burndown
    if @sprint.blank?
      @sprint = find_current_sprint      
    end
    unless @sprint.blank?
      @chart = Burndown.new(@sprint)
    end
  end

  def find_issue
    @issue = Issue.find(params[:id], :include => [:project, :tracker, :status, :author, :priority, :category])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_current_sprint
    @sprint = Version.find(:first,
      :conditions => ["project_id = ? and effective_date > ?", @project.id, Time.now],
      :order => "effective_date ASC")
    if @sprint.nil?
      @sprint = Version.find(:first,
        :conditions => ["project_id = ?", @project.id],
        :order => "effective_date desc")
    end
    @sprint
  end
  
  def assign_to( user_story, params)
    status = params[:status_id].blank? ? nil : IssueStatus.find_by_id(params[:status_id])
    priority = params[:priority_id].blank? ? nil : Enumeration.find_by_id(params[:priority_id])
    assigned_to = (params[:assigned_to_id].blank? || params[:assigned_to_id] == 'none') ? nil : User.find_by_id(params[:assigned_to_id])
    category = (params[:category_id].blank? || params[:category_id] == 'none') ? nil : @project.issue_categories.find_by_id(params[:category_id])
    fixed_version = (params[:sprint].blank? || params[:sprint].eql?('0')) ? nil : @project.versions.find_by_id(params[:sprint])
    
    unsaved_issue_ids = []      
    user_story.issues.each do |issue|
      journal = init_journal(issue,User.current, params[:notes])
      issue.priority = priority if priority
      issue.assigned_to = assigned_to if assigned_to || params[:assigned_to_id] == 'none'
      issue.category = category if category || params[:category_id] == 'none'
      issue.fixed_version = fixed_version
      issue.start_date = params[:start_date] unless params[:start_date].blank?
      issue.due_date = params[:due_date] unless params[:due_date].blank?
      issue.done_ratio = params[:done_ratio] unless params[:done_ratio].blank?
      call_hook(:controller_issues_bulk_edit_before_save, { :params => params, :issue => issue })
      # Don't save any change to the issue if the user is not authorized to apply the requested status
      if (status.nil? || (issue.status.new_status_allowed_to?(status, current_role, issue.tracker) && issue.status = status)) && issue.save
        # Send notification for each issue (if changed)
        Mailer.deliver_issue_edit(journal) if journal.details.any? && Setting.notified_events.include?('issue_updated')
      else
        # Keep unsaved issue ids to display them in flash error
        unsaved_issue_ids << issue.id
      end
    end
    if unsaved_issue_ids.empty?
#      flash[:notice] = l(:notice_successful_update) unless user_story.issues.empty?
    else
#      flash[:error] = l(:notice_failed_to_save_issues, unsaved_issue_ids.size, user_story.issues.size, '#' + unsaved_issue_ids.join(', #'))
    end
  end
  
  def init_journal(issue, user, notes = "")
    @current_journal ||= Journal.new(:journalized => issue, :user => user, :notes => notes)
    @issue_before_change = issue.clone
    @issue_before_change.status_id = issue.status_id
    @custom_values_before_change = {}
#    issue.custom_values.each {|c| @custom_values_before_change.store c.custom_field_id, c.value }
    # Make sure updated_on is updated when adding a note.
    issue.updated_on_will_change!
    @current_journal
  end

end
