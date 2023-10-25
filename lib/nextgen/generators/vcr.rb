install_gems "vcr", "webmock", group: :test
copy_test_support_file "webmock.rb"
template "test/support/vcr.rb.tt", rspec? ? "spec/support/vcr.rb" : "test/support/vcr.rb"
