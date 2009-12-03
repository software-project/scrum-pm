class DiagramsController < ApplicationController
  unloadable
  before_filter :find_project, :only => [:index, :new, :create, :show]
  
  def index
    @diagrams = Diagram.find(:all, :conditions => "thumbnail is null")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @diagrams }
    end
  end

  # GET /diagrams/1
  # GET /diagrams/1.xml
  def show
    @diagram = Diagram.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @diagram }
    end
  end

  # GET /diagrams/new
  # GET /diagrams/new.xml
  def new
    @diagram = Diagram.new
    @diagram.user_story_id = params[:userstory_id]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @diagram }
    end
  end

  # GET /diagrams/1/edit
  def edit
    @diagram = Diagram.find(params[:id])
  end

  # POST /diagrams
  # POST /diagrams.xml
  def create
    @diagram = Diagram.new(params[:diagram])
    @diagram.project_id = @project_id

    if @diagram.save
      flash[:notice] = 'Diagram was created successfully.'
      redirect_to url_for_object(@diagram.user_story.sprint,@project,"show")
    else
      render :action => :new
    end
  end


  # PUT /diagrams/1
  # PUT /diagrams/1.xml
  def update
    @diagram = Diagram.find(params[:id])

    respond_to do |format|
      if @diagram.update_attributes(params[:diagram])
        flash[:notice] = 'Diagram was updated successfully.'
        format.html { redirect_to(@diagram) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @diagram.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /diagrams/1
  # DELETE /diagrams/1.xml
  def destroy
    @diagram = Diagram.find(params[:id])
    @diagram.destroy

    respond_to do |format|
      format.html { redirect_to(diagrams_url) }
      format.xml  { head :ok }
    end
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
end
