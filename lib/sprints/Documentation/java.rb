module Sprints
  module Documentation
    class Java < Sprints::Documentation::Base

      def generate_api
        Dir.chdir("public/projects/#{sprints_setup.path}/repo") {|path|
          %x{javadoc -d html -sourcepath src -subpackages #{packages_names(path)} }
    #       javadoc -d html -sourcepath src -subpackages pl
        }
      end

      def generate_charts
        Dir.chdir("public/projects/#{sprints_setup.path}") {|path|
          filename = sprint_setup.project_id + "_" + sprint_setup.path
          file = File.new( + filename,File::CREAT|File::TRUNC|File::RDWR)
          file.puts iterate_folder_for_code(path + "/repo/src","")
          file.close
          %x{umlgraph #{filename} png}
        }
      end

      private
      def packages_names(path)
        str = ""
        Dir.foreach(path) { |fn|
          str << "#{fn}:" if fn[0] != '.' && File.directory?(fn)
        }
        str.chop
      end

      def iterate_folder_for_code(path,str)
        Dir.foreach(path) { |fn|
          if File.directory?(fn)
            str = iterate_folder_for_code(fn,str)
          else
            if fn =~ /*.java/
              f = File.new(fn,"r")
              while line = f.gets
                if line !~ /[import|package]*/
                  str += line
                else
                  if line =~ /import*/
                    str = line + str
                  end
                end
              end
            end
          end
        }
        str
      end
    end
  end
end