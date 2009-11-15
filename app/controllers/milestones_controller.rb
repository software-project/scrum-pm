class MilestonesController < ApplicationController
  unloadable
  before_filter :find_project
  helper :sprints

  def new
    @milestone = Milestone.new
    @milestone.project_id = @project.id

    render :partial => "milestones/new", :locals => {:milestone => @milestone}
  end


  def create
    @milestone = Milestone.new(params[:milestone])
    @milestone.project_id = @project.id

    if @milestone.save
      render :update do |p|
        p.insert_html :bottom, 'milestones', :partial => "milestones/milestone",:locals => {:milestone => @milestone}
      end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @milestone.errors, :status => :unprocessable_entity }
      end
    end
  end


  def edit
    @milestone = Milestone.find(params[:id])
    render :partial => "milestones/edit", :locals => {:milestone => @milestone}
  end


  def update
    @milestone = Milestone.find(params[:id])

    if @milestone.update_attributes(params[:milestone])
      render :update do |p|
        p.replace "milestone_frame_#{@milestone.id}", :partial => "milestones/milestone",:locals => {:milestone => @milestone}
        p["milestone_frame_#{@milestone.id}"].visual_effect :highlight, :duration => 2
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @milestone.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    @milestone = Milestone.find(params[:id])
    milestone_id = @milestone.id
    @milestone.destroy
    render :update do |p|
      p["milestone_frame_#{milestone_id}"].visual_effect :blind_up, :duration => 1
    end
  end

private
  def find_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
