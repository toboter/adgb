# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

APP_VERSION = `git describe --always` unless defined? APP_VERSION