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

  def chart(width,height)
    Gchart.line(
      :size => "#{width}x#{height}",
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
      }
      total_points_left

    end
  end

  def ideal_data
    [sprint_data.first, 0]
  end

end