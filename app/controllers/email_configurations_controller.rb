=begin rdoc
=Description
Scaffolding for EmailConfiguration Model
=end
class EmailConfigurationsController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart

  include ConfigurationMethods

  def edit_email_configuration
  end

  def save_email_configuration
    email_config = params.clone.delete_if {|k,v| not (k =~ /^(enable_patient|enable_error|patient|error|reply_to|bounce)_email/ or k =~ /^mail/) or v.blank? }
    email_config.each do |k,v|
      EmailConfiguration.update_or_insert(k,v)
    end

    flash[:notice] = 'Email configuration saved'
    redirect_to action: :edit_email_configuration
  end

  def test
  end

  def try_email
    output = Java::OrgRsnaIsnUtil::EmailUtil.send(params[:recipient],"Test email","This test message was sent from the isn image sharing server.")
    render :text => "<pre class=\"well\">#{output}</pre>"
  end

  private
  def model
    EmailConfiguration
  end

end
