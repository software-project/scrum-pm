module RedmineSprints
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, :partial => 'issue_sprints/user_story_field'
    render_on :view_issues_show_details_bottom, :partial => "issue_sprints/redirect_after_create"

    def controller_issues_new_before_save(context = {})
      context[:issue].user_story_id = context[:params][:issue][:user_story_id]
      if context[:issue].user_story_id && context[:issue].fixed_version_id
        if context[:issue].id
           context[:issue].redirect_to = url_for(:controller => :sprints, :action => "show", :id => context[:issue].fixed_version_id, :project_id => context[:issue].project.identifier)+"/"+context[:issue].id
         else
           context[:issue].redirect_to = url_for(:controller => :sprints, :action => "show", :id => context[:issue].fixed_version_id, :project_id => context[:issue].project.identifier)
         end
         puts ":controller_issues_new_before_save 99"
      end
    end
  end
end
