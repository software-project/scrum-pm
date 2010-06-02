module TasksHelper

  def task_developers(task)
    text = String.new
    for user in task.users
      text << (text.size > 0 ? ",":"") +user_initials(user)
    end
    return text
  end

  def user_initials(user)
    i = String.new
    i << user.firstname[0]
    i << user.lastname[0]
  end

  def pagination_links_full(paginator, count=nil, options={})
    page_param = options.delete(:page_param) || :page
    url_param = params.dup
    # don't reuse query params if filters are present
    url_param.merge!(:fields => nil, :values => nil, :operators => nil) if url_param.delete(:set_filter)

    html = ''
    if paginator.current.previous
      html << link_to_remote('&#171; ' + l(:label_previous), {:url => url_param.merge(page_param => paginator.current.previous), :update => 'unassigned_tasks'}) + ' '
    end

    html << (pagination_links_each(paginator, options) do |n|
      link_to_remote(n.to_s, {:url => url_param.merge(page_param => n), :update => 'unassigned_tasks'})
    end || '')
    
    if paginator.current.next
      html << ' ' + link_to_remote((l(:label_next) + ' &#187;'), {:url => url_param.merge(page_param => paginator.current.next), :update => 'unassigned_tasks'})
    end

    unless count.nil?
      html << [
        " (#{paginator.current.first_item}-#{paginator.current.last_item}/#{count})",
        per_page_links(paginator.items_per_page)
      ].compact.join(' | ')
    end

    html
  end

  def per_page_links(selected=nil)
    url_param = params.dup
    url_param.clear if url_param.has_key?(:set_filter)

    links = Setting.per_page_options_array.collect do |n|
      n == selected ? n : link_to_remote(n, {:update => "unassigned_tasks",
                                             :url => params.dup.merge(:per_page => n),
                                             :method => :get},
                                            {:href => url_for(url_param.merge(:per_page => n))})
    end
    links.size > 1 ? l(:label_display_per_page, links.join(', ')) : nil
  end
end
