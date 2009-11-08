# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_lambda-sql_session',
  :secret      => '7da40a830e169f2cd4e8733edaa60d77841a19416224a31e2b734899b1a387710424c949812b7f969436398ccbf0a188b278dcc0a5205e8467fcfd6ce868e219'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
