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
    output = CGI::escapeHTML(`$JAVA_HOME/bin/java -cp $RSNA_ROOT/transfer-content-*.jar org.rsna.isn.transfercontent.test.XdsTest`)
    render :text => "<pre>#{output}</pre>"
  end

  private
  def model
    EdgeConfiguration
  end


end
