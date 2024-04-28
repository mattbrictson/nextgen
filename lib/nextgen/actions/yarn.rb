module Nextgen
  module Actions::Yarn
    def add_yarn_packages(*packages, dev: false)
      add = dev ? "add -D" : "add"
      yarn_command "#{add} #{packages.map(&:shellescape).join(" ")}"
    end
    alias add_yarn_package add_yarn_packages

    def remove_yarn_packages(*packages, capture: false)
      yarn_command "remove #{packages.map(&:shellescape).join(" ")}", capture:
    end
    alias remove_yarn_package remove_yarn_packages

    def add_package_json_scripts(scripts)
      scripts.each do |name, script|
        cmd = "npm pkg set scripts.#{name.to_s.shellescape}=#{script.shellescape}"
        say_status :run, cmd.truncate(60), :green
        run! cmd, verbose: false
      end
    end
    alias add_package_json_script add_package_json_scripts

    def yarn_command(cmd, capture: false)
      say_status :yarn, cmd, :green
      output = run! "yarn #{cmd}", capture: true, verbose: false
      return output if capture
      return puts(output) unless output.match?(/^success /)

      puts output.lines.grep(/^(warning|success) /).join
    end
  end
end
