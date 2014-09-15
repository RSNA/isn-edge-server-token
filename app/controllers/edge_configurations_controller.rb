=begin rdoc
=Description
Scaffolding for EdgeConfiguration Model
=end
class EdgeConfigurationsController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart

  include ConfigurationMethods

  private
  def model
    EdgeConfiguration
  end


end
