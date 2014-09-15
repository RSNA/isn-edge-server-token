=begin rdoc
=Description
Generalized Scaffolding for Configuration Models
=end
module ConfigurationMethods

  # List configuration variables
  def index
    @edge_configurations = model.all()
    render :template => "edge_configurations/index"
  end

  # Form for new configuration variables
  def new
    @edge_configuration = model.new
    render :template => "edge_configurations/new"
  end

  # Form Post handler for new configuration variables
  def create
    @edge_configuration = model.new(params[:edge_configuration])
    if @edge_configuration.save
      flash[:notice] = "New Configuration Variable"
      redirect_to :action => :index
    else
      render :template => "edge_configurations/new"
    end
  end

  # Form for existing configurations variables
  def edit
    @edge_configuration = model.find(params[:id])
    @edge_configuration.given_key = @edge_configuration.key
    render :template => "edge_configurations/edit"
  end

  # Form post handler for updating existing configuration variables
  # Due to the non-conventional primary key this must check if the key
  # has been changed in the form before trying to update.  If it is
  # different it has to create a new record and destroy the old one.
  def update
    @edge_configuration = model.find(params[:id])
    if @edge_configuration.key != params[:edge_configuration][:given_key]
      @new_edge_configuration = model.new(:given_key => params[:edge_configuration][:given_key], :value => params[:edge_configuration][:value])
      if @new_edge_configuration.save
        @edge_configuration.destroy
        flash[:notice] = "Updated Configuration Variable"
        redirect_to :action => :index
      else
        render :template => "edge_configurations/edit"
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
    @edge_configuration = model.find(params[:id])
    if @edge_configuration.destroy
      flash[:notice] = "Configuration Variable Deleted"
      redirect_to :action => :index
    else
      flash[:notice] = "Failed to delete configuration variable"
      redirect_to :action => :index
    end
  end

end
