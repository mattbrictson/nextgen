# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = false
  config.ignore_localhost = true
  config.ignore_host "chromedriver.storage.googleapis.com"
  config.cassette_library_dir = File.expand_path("../cassettes", __dir__)
  config.default_cassette_options = {
    # Enable automatic expiration and re-recording of cassettes
    # re_record_interval: 1.week,
    record: ENV["CI"] ? :none : :once,
    record_on_error: false,
    match_requests_on: %i[method uri body]
  }

  # Make sure headers containing secrets aren't recorded in cassettes and stored in git
  %w[Authorization X-Api-Key].each do |sensitive_header|
    config.filter_sensitive_data("[#{sensitive_header.upcase}]") do |interaction|
      interaction.request.headers[sensitive_header]&.first
    end
  end
end
