require 'uri'

SYSTEM_PATH = 'D:\\Developer\\MGR\\redmine_new\\public\\'

module Sprints
  class ScmController
    attr :repo, true
    attr :project_setup, true

    def initialize(repository, setup)
      self.repo = repository
      self.project_setup = setup
    end

    def download
      Dir.chdir(SYSTEM_PATH) {|path|
        unless File.exists?("projects")
          Dir.mkdir("projects")
        end
        Dir.chdir("projects")
        unless File.exists?(project_setup.path)
          Dir.mkdir(project_setup.path)
        end
        Dir.chdir(project_setup.path)
        Dir.mkdir("repo")
        Dir.mkdir("doc")
        Dir.mkdir("chart")
        case repo.scm_name
        when 'Subversion'
          str = repo.url + (repo.login.nil? ? "" : " --username #{repo.login}") + (repo.password.nil? ? "": " --password #{repo.password}")
          %x{svn checkout #{str} repo }
        when 'Git'
          str = repo.url
          %x{git clone #{str} repo }
        else
        end
      }
    end

    def update
      Dir.chdir(project_path+"\\repo") {|path|
        case repo.scm_name
        when 'Subversion'
          %x{svn update }
        when 'Git'
          %x{git pull }
        else
        end
      }
    end

    def project_path
      SYSTEM_PATH + "\\projects\\" + project_setup.path
    end
  end
end