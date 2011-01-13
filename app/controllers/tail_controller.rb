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
    @transfer_content_log = `tail -n 200 /rsna/logs/transfer-content.log` if File.exists?("/rsna/logs/transfer-content.log")
    @prep_content_log = `tail -n 200 /rsna/logs/transfer-content.log` if File.exists?("/rsna/logs/prep-content.log")
  end
end
