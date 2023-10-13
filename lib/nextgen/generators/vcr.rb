install_gems "vcr", "webmock", group: :test
template "test/support/vcr.rb.tt", rspec? ? "spec/support/vcr.rb" : "test/support/vcr.rb"
