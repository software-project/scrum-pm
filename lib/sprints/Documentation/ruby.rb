module Sprints
  module Documentation
    class Ruby < Sprints::Documentation::Base

      def generate_api(version)
#        result = ""
        FileUtils.mkdir "public/projects/#{sprints_setup.path}/doc/#{version}"
        Dir.chdir("public/projects/#{sprints_setup.path}/repo") {|path|
          result = %x{rake doc:app}
        }
#        print "--------------#{result}------------------"
        Dir.chdir("public/projects/#{sprints_setup.path}"){|path|
          FileUtils.mv("repo/doc/app", "doc/#{version}")
        }
      end

      def generate_charts
#        TODO moving images to rightful places
        Dir.chdir("public/projects/#{sprints_setup.path}/repo") {|path|
          %x{railroad -M -i -a | dot -Tpng > models.png}
          %x{railroad -C -i | neato -Tpng > controllers.png}
        }
        Dir.chdir("public/projects/#{sprints_setup.path}"){|path|
          FileUtils.mv("repo/models.png", "chart/models.png")
          FileUtils.mv("repo/controllers.png", "chart/controllers.png")
        }
      end

    end
  end
end