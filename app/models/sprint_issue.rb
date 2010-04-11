class SprintIssue < Issue
  unloadable
  belongs_to :user_story, :class_name => 'UserStory', :foreign_key => 'user_story_id'

  def validate
    if self.due_date.nil? && @attributes['due_date'] && !@attributes['due_date'].empty?
      errors.add :due_date, :activerecord_error_not_a_date
    end

    if self.due_date and self.start_date and self.due_date < self.start_date
      errors.add :due_date, :activerecord_error_greater_than_start_date
    end

    if start_date && soonest_start && start_date < soonest_start
      errors.add :start_date, :activerecord_error_invalid
    end
  end
end