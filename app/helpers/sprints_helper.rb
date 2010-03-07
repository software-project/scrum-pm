module SprintsHelper

  def classify( count )
    return count == 0 ? 'even' : 'odd'
  end

  def sprint_end( sprint )
    if sprint.start_date and sprint.duration
      sprint.start_date.advance(:days => sprint.duration)
    end
  end

  def done_user_stories( sprint )
    done_counter = 0
    for user_story in sprint.user_stories
      done_counter += done_tasks_in_stories(user_story)
    end
    return done_counter
  end

  def done_tasks_in_stories( user_story )
    done = 0
    done = user_story.issues.find_all{|t| t.done_ratio == 100}.nitems
    if done == 0
      return 0
    end
    done == user_story.issues.nitems ? user_story.time_estimate.value : 0
  end

  def all_user_stories( sprint )
    all_counter = 0
    for user_story in sprint.user_stories
      all_counter += user_story.time_estimate.value;
    end
    return all_counter == 0? 1: all_counter
  end

  def procent_of_sprint_done( sprint )
    if sprint.user_stories.size > 0
      ((done_user_stories( sprint ).to_f / all_user_stories( sprint ).to_f)*100).to_i.to_s + "%"
    else
      0
    end
  end

  def load_sprint_stats(sprint, data)
    if data.size == 0
      data = {:all_points => 0, :pending => 0, :in_progress => 0, :done => 0, :percent_done => 0 }
    end
    if sprint.user_stories.size > 0
      sprint.user_stories.each{|u|
        data[:all_points] += u.time_estimate.value

        pending = 0
        inprogress = 0
        done = 0
        u.issues.each { |i|
          case i.done_ratio
          when 0
            pending += 1
          when 100
            done += 1
          else
            inprogress += 1
          end
        }
        if done == u.issues.size && u.issues.size > 0
          data[:done] += u.time_estimate.value
        else
          if done > 0 || inprogress > 0
            data[:in_progress] += u.time_estimate.value
          else
            data[:pending] += u.time_estimate.value
          end
        end
      }
      data[:percent_done] = ((data[:done]/data[:all_points])*100).to_i.to_s + "%" if data[:all_points] > 0
    end
    data
  end

  def load_project_stats(project)
    data = {:all_points => 0, :pending => 0, :in_progress => 0, :done => 0, :percent_done => 0, :un_assign => 0 }
    UserStory.find(:all, :conditions => ["version_id is null"]).each { |i|
      data[:un_assign] += i.time_estimate.value
    }
    for sprint in Version.find(:all, :conditions => ["project_id = ?",project.id])
      data = load_sprint_stats(sprint, data)
    end
    data[:all_points] += data[:un_assign]
    data[:percent_done] = (data[:done]/(data[:all_points])) * 100 if data[:all_points] != 0

    data
  end

    def link_to_object(object,action)
    link_to_object(object,action,action)
  end

  def link_to_object(object,action,image)
    options = {:controller => object.class.name.pluralize.underscore, :action => action, :project_id => @project}
    if action == "destroy"
      other = {:confirm => 'Are you sure?', :method => :post}
    end
    if action == "destroy" || action == "show" || action == "edit"
       options = options.merge({:id => object.id})
    end
    link_to image_tag("/plugin_assets/redmine_sprints/images/#{image}.png",:title => l(action)), options, other
  end

  def link_to_new_object(object,parent,image)
    options = {:controller => object.pluralize.underscore, :action => "new", :project_id => @project}
    unless parent.nil?
      options = options.merge({(parent.class.name.downcase + "_id").to_sym => parent.id})
    end
    link_to(image_tag("/plugin_assets/redmine_sprints/images/#{image}.png",:title => l("new")), options)
  end             

  def labelled_tabular_form_for(name, object, options, &proc)
    options[:html] ||= {}
    options[:html][:class] = 'tabular' unless options[:html].has_key?(:class)
    form_for(name, object, options.merge({ :builder => TabularFormBuilder, :lang => current_language}), &proc)
  end

  def labelled_tabular_remote_form_for(name, object, options, &proc)
    options[:html] ||= {}
    options[:html][:class] = 'tabular' unless options[:html].has_key?(:class)
    remote_form_for(name, object, options.merge({ :builder => TabularFormBuilder, :lang => current_language}), &proc)
  end
end
