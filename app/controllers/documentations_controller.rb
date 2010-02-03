class DocumentationsController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :find_sprint_setup, :except => [:setup]


  def setup
    @sprint_setup = SprintsSetup.new
    @sprint_setup.language = params[:SprintSetup]
    @sprint_setup.path = @project.identifier
    @sprint_setup.project_id = @project.id
    respond_to do |format|
      if @sprint_setup.save
        scm_ctr = Sprints::ScmController.new(Repository.find_by_project_id(@project.id),@sprint_setup)
        begin
          scm_ctr.download
        rescue
          @sprint_setup.destroy
          Dir.delete(scm_ctr.project_path)
        end
        format.html { redirect_to :back }
      end
    end
  end

  def show_api
    version = 1
    if params[:version] == nil
      version = Documentation.find_by_project_id(@project.id, :order => "version DESC").version
    else
      version = params[:version]
    end
    session[:version] = version
    render :file => "public/projects/#{@project.identifier}/doc/#{version}/app/index.html", :use_full_path => true
  end

  def show_doc
    path=""
    params[:path].each { |item|
      path += item +"/"
    }
    path = path[0..(path.size-2)]
    render :file => "public/projects/#{@project.identifier}/doc/#{session[:version]}/app/#{path}", :use_full_path => true
  end

  def generate_documentation
    generate_doc
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def update_repo
    unless @sprint_setup.nil?
      scm_ctr = Sprints::ScmController.new(Repository.find_by_project_id(@project.id),@sprint_setup)
      scm_ctr.update
      respond_to do |format|

        format.html { redirect_to :back }
      end
    else
    end
  end

  def edit

  end
  
  private

  def generate_doc
#    TODO fix documentation versioning and folders
    documentation = Documentation.new
    case @sprint_setup.language
    when 'Ruby'
      doc = Sprints::Documentation::Ruby.new(@sprint_setup)
    when 'Java'
      doc = Sprints::Documentation::Java.new(@sprint_setup)
    end

    documentation.project_id = @project.id
    documentation.revision = Repository.find_by_project_id(@project.id).changesets.first.revision
    last_doc = Documentation.find_all_by_project_id(@project.id, :order => "version ASC")
    documentation.version = last_doc.nil? || last_doc.size == 0 ? 1 : (last_doc.last.version + 1)

    documentation.save
    
    doc.generate_api(documentation.version)
    doc.generate_charts
  end

  def find_project
    @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def find_sprint_setup
    @sprint_setup = SprintsSetup.find_by_project_id(@project.id)
    rescue ActiveRecord::RecordNotFound
      render_404
  end

end
