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
    @edge_configuration.given_key = @edge_configuration.key
  end

  # Form post handler for updating existing configuration variables
  # Due to the non-conventional primary key this must check if the key
  # has been changed in the form before trying to update.  If it is
  # different it has to create a new record and destroy the old one.
  def update
    @edge_configuration = EdgeConfiguration.find(params[:id])
    if @edge_configuration.key != params[:edge_configuration][:given_key]
      @new_edge_configuration = EdgeConfiguration.new(:given_key => params[:edge_configuration][:given_key], :value => params[:edge_configuration][:value])
      if @new_edge_configuration.save
        @edge_configuration.destroy
        flash[:notice] = "Updated Configuration Variable"
        redirect_to :action => :index
      else
        render :template => "edge_configuration/edit"
      end
    elsif @edge_configuration.update_attributes(params[:edge_configuration])
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
