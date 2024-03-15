require "yaml"

module Nextgen
  class Generators
    def self.compatible_with(rails_opts:, style:, scope:)
      new(scope, api: rails_opts.api?).tap do |generators|
        Nextgen.config_for(style: style, scope: scope).each do |name, options|
          options ||= {}
          requirements = Array(options["requires"])
          next unless requirements.all? { |req| rails_opts.public_send(:"#{req}?") }

          generators.add(
            name.to_sym,
            prompt: options["prompt"],
            description: options["description"],
            node: !!options["node"],
            questions: options["questions"]
          )
        end
        generators.deactivate_node unless rails_opts.requires_node?
      end
    end

    def initialize(scope, **vars)
      @generators = {}
      @variables = vars
      @scope = scope
    end

    def empty? = @generators.empty?

    def ask_select(question, multi: false, sort: false, prompt: TTY::Prompt.new)
      opts = sort ? optional.sort_by { |label, _| label.downcase }.to_h : optional
      args = [question, opts, {cycle: true, filter: true}]
      answers = multi ? prompt.multi_select(*args) : [prompt.select(*args)]

      answers.each do |answer|
        ask_second_level_questions(for_selected: answer, prompt: prompt)
      end
      activate(*answers)
    end

    def ask_second_level_questions(for_selected:, prompt:)
      (generators[for_selected&.to_sym]&.[](:questions) || []).each do |q|
        variables[q.fetch("variable").to_sym] = prompt.public_send(
          q.fetch("method"), "  ↪ #{q.fetch("question")}"
        )
      end
    end

    def node_active?
      !!generators[:node]&.[](:active)
    end

    def all_active
      generators.each_with_object([]) do |(name, meta), result|
        result << name if meta[:active]
      end
    end

    def all_active_names
      opts = optional.invert
      all_active.filter_map { |name| opts[name] }
    end

    def add(name, node: false, prompt: nil, description: nil, questions: nil)
      name = name.to_sym
      raise ArgumentError, "Generator #{name.inspect} was already added" if generators.key?(name)

      generators[name] = {node: node, prompt: prompt, description: description, questions: questions}
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
      generators[:node][:active] = false if generators.key?(:node)
    end

    def to_ruby_script
      apply_statements = all_active.map do |generator|
        description = generators.fetch(generator)[:description]
        path = Nextgen.generators_path(scope).join("#{generator}.rb")
        "apply_as_git_commit #{path.to_s.inspect}, message: #{description.inspect}"
      end

      <<~SCRIPT
        require #{File.expand_path("../nextgen", __dir__).inspect}
        extend Nextgen::Actions
        @variables = #{@variables}

        with_nextgen_source_path do
          #{apply_statements.join("\n  ")}
        end
      SCRIPT
    end

    private

    attr_reader :generators, :variables, :scope
  end
end
