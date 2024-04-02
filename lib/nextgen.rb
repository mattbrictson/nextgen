require "pathname"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/nextgen/generators")
loader.inflector.inflect("cli" => "CLI")
loader.setup

module Nextgen
  def self.generators_path(scope = "")
    Pathname.new(__dir__).join("nextgen/generators", scope)
  end

  def self.template_path
    Pathname.new(__dir__).join("../template")
  end

  def self.config_path(style: nil)
    if style
      if style.match?("/")
        Pathname.new(style)
      else
        Pathname.new(__dir__).join("../config/styles", style)
      end
    else
      Pathname.new(__dir__).join("../config")
    end
  end

  def self.config_for(scope:, style: nil)
    base = YAML.load_file("#{Nextgen.config_path}/#{scope}.yml")
    if style
      base.merge!(YAML.load_file("#{Nextgen.config_path(style: style)}/#{scope}.yml") || {})
    end
    base
  end

  def self.scopes_for(style: nil)
    Dir[Nextgen.config_path(style: style) + "*.yml"].map { _1.match(/([_a-z]*)\.yml/)[1] }
  end
end
