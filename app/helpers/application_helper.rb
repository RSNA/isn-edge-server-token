# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def preview(text, length=400)
    text.split(/\s/).inject("") do |out, chunk|
      if (out.size + 1 + chunk.size) <= length
        out + " " + chunk
      else
        return out + " ..."
      end
    end
  end

  def role_button(user, name, value)
    selected = (user.role_id == value ? true : false)
    content_tag(:span, "#{name}:") +
      radio_button_tag("user_role_#{user.id}", value, selected, :onclick => "update_role(this, #{user.id}, 'update_alert_#{user.id}');")
  end

  def status_for(exam)
    if exam.last_report
      exam.last_report.status
    else
      "Ordered"
    end
  end

  def send_status_for(exam)
    if exam.job
      exam.job.status_message
    else
      "not sent"
    end
  end
end
