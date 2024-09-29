# frozen_string_literal: true

module Nextgen
  module Actions::Javascript
    def add_js_packages(*packages, dev: false)
      command = yarn? ? +"yarn add" : +"npm install --fund=false --audit-false"
      command << " -D" if dev
      run_js_command "#{command} #{packages.map(&:shellescape).join(" ")}"
    end
    alias add_js_package add_js_packages

    def remove_js_packages(*packages, capture: false)
      command = yarn? ? "yarn remove" : "npm uninstall"
      run_js_command "#{command} #{packages.map(&:shellescape).join(" ")}", capture:
    end
    alias remove_js_package remove_js_packages

    def add_package_json_scripts(scripts)
      scripts.each do |name, script|
        cmd = "npm pkg set scripts.#{name.to_s.shellescape}=#{script.shellescape}"
        say_status :run, cmd.truncate(60), :green
        run! cmd, verbose: false
      end
    end
    alias add_package_json_script add_package_json_scripts

    def remove_package_json_script(name)
      cmd = "npm pkg delete scripts.#{name.to_s.shellescape}"
      say_status :run, cmd.truncate(60), :green
      run! cmd, verbose: false
    end

    def js_package_manager
      File.exist?("yarn.lock") ? :yarn : :npm
    end

    def yarn?
      js_package_manager == :yarn
    end

    def run_js_command(cmd, capture: false)
      say_status(*cmd.split(" ", 2), :green)
      output = run! cmd, capture: true, verbose: false
      return output if capture
      return puts(output) unless output.match?(/^success /)

      puts output.lines.grep(/^(warning|success) /).join
    end
  end
end
