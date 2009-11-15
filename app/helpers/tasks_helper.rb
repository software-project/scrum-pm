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
end
