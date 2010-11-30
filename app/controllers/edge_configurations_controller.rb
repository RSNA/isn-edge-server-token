=begin rdoc
=Description
Scaffolding for EdgeConfiguration Model
=end
class EdgeConfigurationsController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart

  # List configuration variables
  def index
    @edge_configurations = EdgeConfiguration.all()
  end

  # Form for new configuration variables
  def new
    @edge_configuration = EdgeConfiguration.new
  end

  # Form Post handler for new configuration variables
  def create
    @edge_configuration = EdgeConfiguration.new(params[:edge_configuration])
    if @edge_configuration.save
      flash[:notice] = "New Configuration Variable"
      redirect_to :action => :index
    else
      render :template => "edge_configurations/new"
    end
  end

  # Form for existing configurations variables
  def edit
    @edge_configuration = EdgeConfiguration.find(params[:id])
  end

  # Form post handler for updating existing configuration variables
  def update
    @edge_configuration = EdgeConfiguration.find(params[:id])
    if @edge_configuration.update_attributes(params[:edge_configuration])
      flash[:notice] = "Updated Configuration Variable"
      redirect_to :action => :index
    else
      render :template => "edge_configurations/edit"
    end
  end

  # Deletes specified configuration variable
  def destroy
    @edge_configuration = EdgeConfiguration.find(params[:id])
    if @edge_configuration.destroy
      flash[:notice] = "Configuration Variable Deleted"
      redirect_to :action => :index
    else
      flash[:notice] = "Failed to delete configuration variable"
      redirect_to :action => :index
    end
  end

end
