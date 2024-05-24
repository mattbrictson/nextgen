# frozen_string_literal: true

module Nextgen
  class TidyGemfile
    def self.clean!(path = "Gemfile")
      gemfile = new(path)
      gemfile.clean
      gemfile.save
    end

    def initialize(path = "Gemfile")
      @path = path
      @gemfile = File.read(path)
    end

    def include?(gem)
      gemfile.match?(/^\s*gem\s+['"]#{gem}['"]/)
    end

    def clean
      @gemfile = gemfile
        .gsub(/^\s*#.*/, "")          # remove comments
        .gsub(/(\s*\n)+/, "\n")       # remove blank lines
        .gsub(/^(ruby.*)/, "\n\\1\n") # ensure blank space around "ruby" line
        .gsub(/^(group.*)/, "\n\\1")  # ensure blank space before each "group" block
      nil
    end

    def add(gem, version: nil, group: nil, require: nil)
      return false if include?(gem)

      gem_line = build_gem_line(gem, version:, require:, indent: group ? "  " : "")

      if group
        group_line = create_group_if_needed(group)
        gemfile.sub!(/#{Regexp.quote(group_line)}/, '\0' + gem_line)
      else
        gemfile.sub!(/^(#|gem\s)/, gem_line + '\0')
      end

      # Add a blank line after the gem if the subsequent line starts with a comment
      gemfile.sub!(/(#{Regexp.quote(gem_line)})(\s*#)/, "\\1\n\\2")
      true
    end

    def remove(gem)
      !!gemfile.gsub!(/^( *#.*?\n)?\s*gem\s+['"]#{gem}['"].*\n/, "")
    end

    def save
      File.write(@path, gemfile.rstrip + "\n")
      true
    end

    private

    attr_reader :gemfile

    def create_group_if_needed(group)
      group_line = "group " + Array(group).map(&:inspect).join(", ") + " do\n"
      gemfile << "\n#{group_line}end\n" unless gemfile.include?(group_line)
      group_line
    end

    def build_gem_line(gem, version:, require:, indent:)
      line = %(gem "#{gem}")
      line += ", #{version.to_s.inspect}" if version
      line += ", require: #{require.inspect}" unless require.nil?

      indent + line + "\n"
    end
  end
end
