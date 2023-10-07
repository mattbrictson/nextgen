require "pathname"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/nextgen/generators")
loader.inflector.inflect("cli" => "CLI")
loader.setup

module Nextgen
  def self.generators_path
    Pathname.new(__dir__).join("nextgen/generators")
  end

  def self.template_path
    Pathname.new(__dir__).join("../template")
  end
end
