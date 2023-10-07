require "test_helper"
require "fileutils"
require "open3"
require "securerandom"

class NextgenIntegrationTest < Minitest::Test
  def test_nextgen_generates_rails_app
    assert_bundle_exec_nextgen_create(stdin_data: "\n\n\n\n\n\n\n\n\n\n\u0001\n\n")
  end

  def test_nextgen_generates_vite_rails_app
    assert_bundle_exec_nextgen_create(stdin_data: "\n\n\n\n\e[B\e[B\n\n\n\n\u0001\n\n")
  end

  def test_nextgen_generates_rspec_rails_app
    assert_bundle_exec_nextgen_create(stdin_data: "\n\n\n\n\n\n\n\n\e[B\n\n\u0001\n\n")
  end

  private

  def assert_bundle_exec_nextgen_create(stdin_data:)
    in_temp_dir do
      bundle_exec! "nextgen create myapp", stdin_data: stdin_data
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

  def in_temp_dir(&block)
    token = SecureRandom.hex(8)
    dir = File.join(Dir.tmpdir, "nextgen_test_#{token}")
    FileUtils.mkdir_p(dir)
    Dir.chdir(dir, &block)
  end
end
