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
      file = "prep-content.log"
    else
      file = "transfer-content.log"
    end

    @log = `tail -n 200 /rsna/logs/#{file}` if File.exists?("/rsna/logs/#{file}")
    @log ||= "The log file is empty"
  end

end
