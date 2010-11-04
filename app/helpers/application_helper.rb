# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def super?(&block)
    if @user and (@user.super? or @user.admin?)
      concat(capture(&block))
    end
  end

  def admin?(&block)
    if @user and @user.admin?
      concat(capture(&block))
    end
  end

  def logged_in_user?(&block)
    if @user
      concat(capture(&block))
    end
  end

  def patient?(&block)
    if @patient and @patient.rsna_id
      concat(capture(&block))
    end
  end

  def logged_in?
    @user
  end

  def rights?(level)
    logged_in? and @user.role_id >= level
  end

  def tab_active?(name)
    if ["users","admin"].include?(params[:controller]) and params[:action] != "change_password"
      if name == :administrative
        true
      else
        false
      end
    elsif name != :administrative
      true
    end
  end

  def tab_controller(name, *args)
    active = (tab_active?(name) ? "active" : "")
    content_tag(:span, :class => "tab-controller #{active}") do
      link_to(name.to_s.titleize, *args)
    end
  end

  def tabs_for(name,&block)
    active = (tab_active?(name) ? "active-tabs" : "")
    concat(content_tag(:div, :class => "tabs #{active}", :id => "#{name}_tabs") do
      capture(&block)
    end)
  end

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

  def rsna_id_without_pin(id)
    id_items = id.split("-")
    id_items.pop
    id_items.join("-")
  end
end
