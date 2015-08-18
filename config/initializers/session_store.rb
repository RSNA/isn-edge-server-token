# Configure the TorqueBox Servlet-based session store.
# Provides for server-based, in-memory, cluster-compatible sessions
if ENV['TORQUEBOX_APP_NAME']
  TokenApp::Application.config.session_store :cache_store
else
  TokenApp::Application.config.session_store :cookie_store, :key => '_isn_token_app_session'
end  
