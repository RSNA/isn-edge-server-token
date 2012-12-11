=begin rdoc
=Description
Contains methods to be used by the views. Methods added to this helper will be available to all templates in the application.
=end
module ApplicationHelper

  # Used to only show the block when the user is a super user
  def super?(&block)
    if @user and (@user.super? or @user.admin?)
      concat(capture(&block))
    end
  end

  # Used to only show the block when the user is an administartor
  def admin?(&block)
    if @user and @user.admin?
      concat(capture(&block))
    end
  end

  # Used to only show the block when the user is logged in
  def logged_in_user?(&block)
    if @user
      concat(capture(&block))
    end
  end

  # Used to only show the block when a @patient instance variable exists
  def patient?(&block)
    if @patient and @patient.consented?
      concat(capture(&block))
    end
  end

  # Returns the logged in user, if none then returns nil
  def logged_in?
    if @user and @user.respond_to?(:role_id)
      @user
    else
      false
    end
  end

  # Returns true or false if the logged in user has a role level greater than or equal to that which is given
  def rights?(level)
    logged_in? and @user.role_id >= level
  end

  # Returns true or false after checking controller information to determine which tab group is active
  def tab_active?(name)
    if ["tail", "users","admin","devices","edge_configurations"].include?(params[:controller]) and params[:action] != "change_password"
      if name == :administrative
        true
      else
        false
      end
    elsif name != :administrative
      true
    end
  end

  # Builds a tab controller button
  def tab_controller(name, *args)
    active = (tab_active?(name) ? "active" : "")
    content_tag(:span, :class => "tab-controller #{active}") do
      link_to(name.to_s.titleize, *args)
    end
  end

  # Builds a tab with the given information
  def tabs_for(name,&block)
    active = (tab_active?(name) ? "active-tabs" : "")
    if active.blank?
      ""
    else
      concat(content_tag(:div, :class => "tabs #{active}", :id => "#{name}_tabs") do
               capture(&block)
             end)
    end
  end

  # Shows a text preview limited to the length given
  def preview(text, length=400)
    text.split(/\s/).inject("") do |out, chunk|
      if (out.size + 1 + chunk.size) <= length
        out + " " + chunk
      else
        return out + " ..."
      end
    end
  end

  # Builds a button for updating a user role
  def role_button(user, name, value)
    selected = (user.role_id == value ? true : false)
    content_tag(:span, "#{name}:") +
      radio_button_tag("user_role_#{user.id}", value, selected, :onclick => "update_role(this, #{user.id}, 'update_alert_#{user.id}');")
  end

  def status_button(user, name, value)
    selected = (user.active == value ? true : false)
    content_tag(:span, "#{name}:") +
      radio_button_tag("user_status_#{user.id}", value, selected, :onclick => "update_status(this, #{user.id}, 'update_alert_#{user.id}');")
  end


  # Returns the report status of the given exam
  def status_for(exam)
    if exam.last_report
      exam.last_report.status
    else
      "Ordered"
    end
  end

  # Returns the send status of the given exam
  def send_status_for(exam)
    if exam.job_transaction
      exam.job_transaction.comments
    else
      "not sent"
    end
  end

  # Checks if consent has already been given
  # and returns the appropriate action button
  def obtain_consent_button(patient)
    if patient.consented?
      button_to("Select", :controller => :exams, :action => :index, :patient_id => patient.id)
    else
      button_to_function("Select", "obtain_consent(#{patient.id},$.parseJSON('#{patient.attributes.to_json.gsub("'","\\\\'")}'))")
    end
  end

end
