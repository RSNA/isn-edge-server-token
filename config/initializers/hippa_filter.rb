# Include hook code here

require 'hipaa_filter/hipaa_filter/hipaa_log'
ActionController::Base.send(:extend, HipaaLog::ControllerFilters)
