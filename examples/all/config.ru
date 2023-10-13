# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

use Rack::CanonicalHost, ENV.fetch("RAILS_HOSTNAME", nil) if ENV["RAILS_HOSTNAME"].present?
run Rails.application
Rails.application.load_server
