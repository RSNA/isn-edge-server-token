=begin rdoc
=Description
Contains methods to be used by the views. Methods added to this helper will be available to all templates in the application.
=end
module ApplicationHelper

  # Used to only show the block when the user is a super user
  def super?(&block)
    if @sso_groups.include?("Super") || @sso_groups.include?("Admin") || @user.role_id >= 1
      concat(capture(&block))
    end
  end

  # Used to only show the block when the user is an administartor
  def admin?(&block)
    if @sso_groups.include?("Admin") || @user.role_id >= 2
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

  def global_navigation_link(title,url_opts, matching_url_ops = {})
    matching_url_ops = url_opts if matching_url_ops == {}
    matches = matching_url_ops.keys.collect {|key| matching_url_ops[key].to_s == params[key].to_s ? true : false }
    matches.include?(false) ? active = "" : active = "active"
    content_tag(:li, link_to(title, url_opts, :name => title.downcase.gsub(" ","-").gsub("/","")), :class => active)
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
    content_tag(:label, class: "btn btn-primary #{selected ? 'active' : ''}", onclick: "update_role(this, #{user.id}, 'update_alert_#{user.id}'); return false;") do
      radio_button_tag("user_role_#{user.id}", value, selected) + name
    end
  end

  def user_role_selectors(user)
    buttons = role_button(user, "User", 0) + role_button(user, "Super User", 1) + role_button(user, "Admin", 2)
    content_tag(:div, class: "btn-group", "data-toggle" => "buttons") { buttons.html_safe }
  end

  def status_button(user, name, value)
    selected = (user.active == value ? true : false)
    content_tag(:label, class: "btn btn-primary #{selected ? 'active' : ''}", :onclick => "update_status(this, #{user.id}, 'update_alert_#{user.id}'); return false;") do
      radio_button_tag("user_status_#{user.id}", value, selected) + name
    end
  end

  def user_active_selectors(user)
    values = [true, false]
    buttons = values.inject("") {|out,value| out + status_button(user,(value ? 'Active' : 'Disabled'),value) }
    content_tag(:div, class: "btn-group", "data-toggle" => "buttons") { buttons.html_safe }
  end

  # Button for adding to cart if it's not already it it
  def cart_add_button(cart,exam)
    if cart.include?(exam.id)
      button_to("View Cart (#{cart.size})", {controller: :exams, action: :show_cart}, class: "btn btn-primary view-cart")
    else
      button_to("Add to Cart", "#", id: "add_link_#{exam.id}", data: exam.id, class: "btn btn-primary add-to-cart", onclick: "return add_to_cart('add_link_#{exam.id}', #{exam.id});")
    end
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
      button_to("Select", {controller: :exams, action: :index, patient_id: patient.id}, {class: "btn btn-primary"})
    else
      button_to("Select", "#", onclick: "obtain_consent(#{patient.id},$.parseJSON(#{patient.attributes.to_json.to_json}));return false;", class: "btn btn-primary")
    end
  end

  def job_name(job)
    "Acc ##{job.exam.accession_number} - Job ##{job.job_id}#{job.job_transactions.last.status.status_code < 0 ? " (error)" : ""}"
  end

  def pagination(limit,offset,count,&block)
    if count > 0
      content = capture(&block)
      disable_previous = "disabled" if offset <= 0
      disable_next = "disabled" if offset + limit >= count
      locals = {
        :limit => limit,
        :offset => offset,
        :count => count,
        :disable_previous => disable_previous,
        :disable_next => disable_next,
        :content => content,
      }
      locals[:locals] = locals.clone
      return render(:partial => "admin/paginator", :locals => locals)
    else
      return render(html: "No Audits")
    end
  end

  # formats token or access code for readability
  def format_token(token)
    content_tag(:span, token.split("").inject("") {|memo,char| memo += "-" if memo.size > 0 and memo.gsub("-","").size % 5 == 0; memo += char }, :class => "monospace")
  end

end
