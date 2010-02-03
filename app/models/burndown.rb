class Burndown
  attr_accessor :dates, :version, :start_date

  delegate :to_s, :to => :chart

  def initialize(version)
    self.version = version
    versions = Version.find(:all,:conditions => ["project_id = ?", version.project_id], :order => "effective_date")
    pos = versions.index(version)
    if pos == 0
      self.start_date = version.created_on.to_date
    else
      self.start_date = versions[pos-1].effective_date.to_date
    end
    end_date = version.effective_date.to_date
    self.dates = (start_date..end_date).inject([]) { |accum, date| accum << date }
  end

  def chart
    html = ""
    sprint_data.each{|i|
       html << "-#{i}-"
    }
    print "----------------#{html}-----------------"
    Gchart.line(
      :size => '600x200',
      :data => data,
      :axis_with_labels => 'x,y',
      :axis_labels => [dates.map {|d| d.strftime("%m-%d") }],
      :custom => "chxr=1,0,#{sprint_data.max}",
      :line_colors => "DDDDDD,FF0000"
    )
  end

  def data
    [ideal_data, sprint_data]
  end

  def sprint_data
    @sprint_data ||= dates.map do |date|

      total_points_left = 0
      version.user_stories.each{|user_story|
        if !user_story.is_done?(date)
          total_points_left += user_story.story_points
        end
        print "----------------#{user_story.is_done?(date)}-----------------"
      }
      total_points_left

#      user_stories.inject(0) do |total_hours_left, user_story|
#        if !user_story.is_done?(date)
#          total_hours_left -= user_story.story_points
#        else
#          total_hours_left += 0
#        end
#      end

#        done_ratio_details = issue.journals.map(&:details).flatten.select {|detail| 'done_ratio' == detail.prop_key }
#        details_today_or_earlier = done_ratio_details.select {|a| a.journal.created_on.to_date <= date }
#        last_done_ratio_change = details_today_or_earlier.sort_by {|a| a.journal.created_on }.last
#
#        ratio = if last_done_ratio_change
#          last_done_ratio_change.value
#        elsif done_ratio_details.size > 0
#          0
#        else
#          issue.done_ratio.to_i
#        end
    end
      
#      issues = all_issues.select {|issue| issue.created_on.to_date <= date }
#      issues.inject(0) do |total_hours_left, issue|
#        done_ratio_details = issue.journals.map(&:details).flatten.select {|detail| 'done_ratio' == detail.prop_key }
#        details_today_or_earlier = done_ratio_details.select {|a| a.journal.created_on.to_date <= date }
#
#        last_done_ratio_change = details_today_or_earlier.sort_by {|a| a.journal.created_on }.last
#
#        ratio = if last_done_ratio_change
#          last_done_ratio_change.value
#        elsif done_ratio_details.size > 0
#          0
#        else
#          issue.done_ratio.to_i
#        end
#
#        total_hours_left += (issue.estimated_hours.to_i * (100-ratio.to_i)/100)
#      end
#    end
  end

  def ideal_data
    [sprint_data.first, 0]
  end

end