# frozen_string_literal: true

require "test_helper"
require "securerandom"
require "tmpdir"
require "rails/generators/test_case"
require "rails/generators/rails/app/app_generator"

class Nextgen::Generators::TestCase < Rails::Generators::TestCase
  private

  def empty_destination_gemfile
    Pathname.new(destination_root).join("Gemfile").write(<<~GEMFILE)
      source "https://rubygems.org"
    GEMFILE
  end

  def touch_destination_paths(*paths)
    paths.flatten.each do |path|
      dest = Pathname.new(destination_root).join(path)
      FileUtils.mkdir_p dest.dirname
      FileUtils.touch dest
    end
  end

  def apply_generator(name = self.class.name.underscore[/(\w+)_test$/, 1])
    generators = Nextgen::Generators.new
    generators.add(name)
    script = generators.to_ruby_script
    script_path = new_tempfile_path
    File.write(script_path, script)

    capture(:stdout) do
      Dir.chdir(destination_root) do
        apply_rails_template(script_path)
      end
    end
  end

  def new_tempfile_path
    token = SecureRandom.hex(8)
    File.join(Dir.tmpdir, "nextgen_test_#{token}.rb")
  end

  def apply_rails_template(template)
    generator = Rails::Generators::AppGenerator.new(
      [destination_root],
      {template: template.to_s},
      {destination_root:}
    )
    generator.set_default_accessors!
    generator.apply_rails_template
  end
end
