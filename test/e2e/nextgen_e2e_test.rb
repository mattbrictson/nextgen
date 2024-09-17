# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "open3"
require "securerandom"

class NextgenE2ETest < Minitest::Test
  VERSION_KEYSTROKES = {
    current: "",
    edge: "\e[B",
    main: "\e[B\e[B"
  }.freeze

  FRONTEND_KEYSTROKES = {
    default: "",
    vite: "\e[B\e[B"
  }.freeze

  TEST_FRAMEWORK_KEYSTROKES = {
    minitest: "",
    rspec: "\e[B"
  }.freeze

  def test_nextgen_generates_rails_app
    version_keys = VERSION_KEYSTROKES.fetch((ENV["NEXTGEN_VERSION"] || "current").to_sym)
    frontend_keys = FRONTEND_KEYSTROKES.fetch((ENV["NEXTGEN_FRONTEND"] || "default").to_sym)
    test_framework_keys = TEST_FRAMEWORK_KEYSTROKES.fetch((ENV["NEXTGEN_TEST_FRAMEWORK"] || "minitest").to_sym)

    stdin_data = "\n" + version_keys + "\n\n\n" + frontend_keys + "\n\n\n\n\n" + test_framework_keys + "\n\n\u0001\n\n"

    assert_bundle_exec_nextgen_create(stdin_data:)
  end

  private

  def assert_bundle_exec_nextgen_create(stdin_data:)
    in_temp_dir do
      bundle_exec!("nextgen create myapp", stdin_data:)
      Bundler.with_original_env do
        Dir.chdir("myapp") do
          bundle_exec!("bin/setup")
          bundle_exec!("rake")
        end
      end
    end
  end

  def bundle_exec!(command, stdin_data: "")
    status = Open3.popen2("bundle exec #{command}") do |stdin, stdout, wait_thread|
      stdin << stdin_data
      stdin.close
      out = Thread.new do
        while (line = stdout.gets)
          puts line
        end
      end
      out.join
      wait_thread.value
    end

    assert(status.success?, "Expected #{command.inspect} to run without error")
  end

  def in_temp_dir(&)
    token = SecureRandom.hex(8)
    dir = File.join(Dir.tmpdir, "nextgen_test_#{token}")
    FileUtils.mkdir_p(dir)
    Dir.chdir(dir, &)
  end
end
