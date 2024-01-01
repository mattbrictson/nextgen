require "yaml"

module Nextgen
  class Generators
    def self.compatible_with(rails_opts:)
      yaml_path = File.expand_path("../../config/generators.yml", __dir__)
      new.tap do |g|
        YAML.load_file(yaml_path).each do |name, options|
          options ||= {}
          requirements = Array(options["requires"])
          next unless requirements.all? { |req| rails_opts.public_send(:"#{req}?") }

          g.add(
            name.to_sym,
            prompt: options["prompt"],
            description: options["description"],
            node: !!options["node"]
          )
        end

        g.deactivate_node unless rails_opts.requires_node?
      end
    end

    def initialize
      @generators = {}
    end

    def node_active?
      !!generators.fetch(:node)[:active]
    end

    def all_active
      generators.each_with_object([]) do |(name, meta), result|
        result << name if meta[:active]
      end
    end

    def add(name, node: false, prompt: nil, description: nil)
      name = name.to_sym
      raise ArgumentError, "Generator #{name.inspect} was already added" if generators.key?(name)

      generators[name] = {node: node, prompt: prompt, description: description}
      activate(name) unless prompt
    end

    def optional
      generators.each_with_object({}) do |(name, meta), result|
        result[meta[:prompt]] = name if meta[:prompt]
      end
    end

    def activate(*optional_generators)
      optional_generators.each do |name|
        name = name.to_sym
        gen = generators.fetch(name)
        gen[:active] = true
        activate(:node) if name != :node && gen[:node]
      end
    end

    def deactivate_node
      generators.fetch(:node)[:active] = false
    end

    def to_ruby_script
      apply_statements = all_active.map do |generator|
        description = generators.fetch(generator)[:description]
        path = Nextgen.generators_path.join("#{generator}.rb")
        "apply_as_git_commit #{path.to_s.inspect}, message: #{description.inspect}"
      end

      <<~SCRIPT
        require #{File.expand_path("../nextgen", __dir__).inspect}
        extend Nextgen::Actions

        with_nextgen_source_path do
          #{apply_statements.join("\n  ")}
        end
      SCRIPT
    end

    private

    attr_reader :generators
  end
end
