=begin rdoc
=Description
Scaffolding for SMSConfiguration Model
=end
class SmsConfigurationsController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart

  include ConfigurationMethods

  def edit_sms_configuration
  end

  def save_sms_configuration
    sms_config = params.clone.delete_if {|k,v| not (k =~/^(enable_sms|token|sender|body|account_id|proxy_set|proxy_host|proxy_port)/)}
    sms_config.each do |k,v|
      SMSConfiguration.update_or_insert(k,v)
    end

    flash[:notice] = 'SMS configuration saved'
    redirect_to action: :edit_sms_configuration
  end

  def test
  end

  # def try_email
  #   output = CGI::escapeHTML(Java::OrgRsnaIsnUtil::EmailUtil.send(params[:email],"Test email","This test message was sent from the isn image sharing server."))
  #   render :text => "<pre>#{output}</pre>"
  # end

  private
  def model
    SMSConfiguration
  end

end
