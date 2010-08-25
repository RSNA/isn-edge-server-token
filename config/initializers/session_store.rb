# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_sti-edge_session',
  :secret      => '5b0b729b7083d4566839ead1c418f1eec888b102d40f9fa2a827de00e7cf4817e8c6b14abe8541f19ebc72c6f481e447ffc685681e4f5e6119e0d1bb2434507f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
