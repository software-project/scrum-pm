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
      user_stories = all_user_stories.select {|user_story| user_story.created_on.to_date <= date }
      user_stories.inject(0) do |total_hours_left, user_story|
# to trzeba przerobic na us zeby lecial dla kazdego issue       
        done_ratio_details = issue.journals.map(&:details).flatten.select {|detail| 'done_ratio' == detail.prop_key }
        details_today_or_earlier = done_ratio_details.select {|a| a.journal.created_on.to_date <= date }
        last_done_ratio_change = details_today_or_earlier.sort_by {|a| a.journal.created_on }.last

        ratio = if last_done_ratio_change
          last_done_ratio_change.value
        elsif done_ratio_details.size > 0
          0
        else
          issue.done_ratio.to_i
        end

      end
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

  def ideal_data                                                                             er

    [sprint_data.first, 0]
  end

  def all_user_stories
#    version.fixed_issues.find(:all, :include => [{:journals => :details}, :relations_from, :relations_to])
    version.user_stories
  end
end