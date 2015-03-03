=begin rdoc
=Description
Scaffolding for EdgeConfiguration Model
=end
class EdgeConfigurationsController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart

  include ConfigurationMethods

  def test
  end

  def try_xds
    output = Java::OrgRsnaIsnTransfercontentTest::XDStest.submit()
    render :text => "<pre class=\"well\">#{output}</pre>"
  end

  private
  def model
    EdgeConfiguration
  end


end
