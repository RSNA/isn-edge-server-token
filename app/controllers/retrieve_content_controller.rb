=begin rdoc
=Description
Handles the requests for most administrative tasks.

=Filters
All methods are filtered using the following methods
  super_authenticate # => ensures that the user is a super user or admin
  get_cart # => populates the cart continuation so that the selected patient isn't lost
  hipaa_filter # => Tracks all hipaa data
=end
class RetrieveContentController < ApplicationController
  before_filter :authenticate

  def index
  end

  def send_zip
    @retrieve = File.join([`echo $RSNA_ROOT`.strip,"client_downloads","retrieve-content.zip"])
    send_file(@retrieve)
  end

  def send_key
    @truststore = File.join([`echo $RSNA_ROOT`.strip,"client_downloads","keystore.jks"])
    send_file(@truststore)
  end

end
