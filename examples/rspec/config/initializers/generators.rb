# frozen_string_literal: true

Rails.application.config.generators do |g|
  # Disable generators we don't need.
  g.javascripts false
  g.stylesheets false
g.routing_specs false
g.view_specs false
end
