class DevicesController < ApplicationController
  before_filter :super_authenticate
  before_filter :get_cart

  def index
    @devices = Device.all()
  end

  def new
    @device = Device.new
  end

  def create
    @device = Device.new(params[:device])
    if @device.save
      flash[:notice] = "New Device Added"
      redirect_to :action => :index
    else
      render :template => "devices/new"
    end
  end

  def edit
    @device = Device.find(params[:id])
  end

  def update
    @device = Device.find(params[:id])
    if @device.update_attributes(params[:device])
      flash[:notice] = "Updated Device"
      redirect_to :action => :index
    else
      render :template => "devices/edit"
    end
  end

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
