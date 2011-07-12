=begin rdoc
=Description
Tails the rsna edge servers logs
=end
class TailController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart
  hipaa_filter

  # Tails the last 200 lines of the concatenated edge server log
  def index
    if params[:log] == "prepare-content"
      file = File.join([`echo $RSNA_ROOT`.strip,"logs","prep-content.log"])
    elsif params[:log] == "transfer-content"
      file = File.join([`echo $RSNA_ROOT`.strip,"logs","transfer-content.log"])
    else
      file = File.join([RAILS_ROOT,"log",RAILS_ENV + ".log"])
      params[:log] = "token-app"
    end

    @log = `tail -n 200 #{file}` if File.exists?(file)
    @log ||= "The log file (#{file}) is empty"
  end

end
