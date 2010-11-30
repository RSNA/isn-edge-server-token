=begin rdoc
=Description
Scaffolding for the Device model
=end
class DevicesController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart

  # List all devices
  def index
    @devices = Device.all()
  end

  # Form for a new device
  def new
    @device = Device.new
  end

  # Form Post handler for new devices
  def create
    @device = Device.new(params[:device])
    if @device.save
      flash[:notice] = "New Device Added"
      redirect_to :action => :index
    else
      render :template => "devices/new"
    end
  end

  # Form for existing devices
  def edit
    @device = Device.find(params[:id])
  end

  # Form Post handler for updating existing devices
  def update
    @device = Device.find(params[:id])
    if @device.update_attributes(params[:device])
      flash[:notice] = "Updated Device"
      redirect_to :action => :index
    else
      render :template => "devices/edit"
    end
  end

  # Deletes specified device
  def destroy
    @device = Device.find(params[:id])
    if @device.destroy
      flash[:notice] = "Device Deleted"
      redirect_to :action => :index
    else
      flash[:notice] = "Failed to delete device"
      redirect_to :action => :index
    end
  end

end
