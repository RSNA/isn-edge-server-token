module EdgeConfigurationsHelper

  def email_value_for(key)
    EmailConfiguration.value_for(key)
  end

  def email_type_checkbox(property,title)
    checked = email_value_for(property) == 'true' ? true : false
    content_tag(:div, class: "checkbox") do
      content_tag(:label) do
        check_box_tag("control-for-#{property}","true",checked, class: "complex-checkbox") + hidden_field_tag(property,checked.to_s) + title
      end
    end
  end

end
