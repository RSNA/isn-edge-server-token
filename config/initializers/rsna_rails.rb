# Include hook code here
#ActionController::Base.send(:include, SomSkin::ControllerMethods) #Produces bizarre no method responded to action behavior

require "rsna_tables"
ActionView::Base.send(:include, RSNARailsExtensions::Helpers)
