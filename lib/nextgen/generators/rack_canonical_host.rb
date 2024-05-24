# frozen_string_literal: true

say_git "Install rack-canonical-host"
install_gem "rack-canonical-host"

say_git "Use RAILS_HOSTNAME env var"
document_deploy_var "RAILS_HOSTNAME", "Redirect all requests to the specified canonical hostname"
insert_into_file "config.ru",
  %(use Rack::CanonicalHost, ENV.fetch("RAILS_HOSTNAME", nil) if ENV["RAILS_HOSTNAME"].present?\n),
  before: /^run Rails.application/
