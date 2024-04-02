install_gems "vcr", "webmock", group: :test
copy_test_support_file "vcr.rb.tt"
copy_test_support_file "webmock.rb"
append_to_file ".gitattributes", <<~GITATTRS if File.exist?(".gitattributes")

  # Mark VCR cassettes as having been generated.
  #{rspec? ? "spec" : "test"}/cassettes/* linguist-generated
GITATTRS
