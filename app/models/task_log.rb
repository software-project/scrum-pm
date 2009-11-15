class TaskLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  belongs_to :status
  belongs_to :sprint
end
