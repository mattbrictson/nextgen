require "open3"
require "securerandom"
require "shellwords"
require "tmpdir"

module Nextgen
  module Actions::Git
    def say_git(message)
      @commit_messages << message if @commit_messages
      say message, :cyan
    end

    def apply_as_git_commit(path, message: nil)
      say message, :cyan if message
      @commit_messages = []
      initially_clean = git_working? && git_status == :clean
      say_status :apply, File.basename(path)
      apply path, verbose: false
      return if !initially_clean || git_status == :clean

      commit = message&.dup || "Apply #{File.basename(path)} generator from nextgen"
      commit << ("\n\n- " + @commit_messages.join("\n- ")) unless @commit_messages.empty?
      git_commit_all(commit)
    ensure
      @commit_messages = nil
    end

    def git_commit_all(msg)
      tmp_file = File.join(Dir.tmpdir, "nextgen_git_message_#{SecureRandom.hex(8)}.rb")
      File.write(tmp_file, msg.rstrip + "\n")

      git add: ".", commit: "-F #{tmp_file.shellescape}"
    end

    def git_working?
      return @git_working if defined?(@git_working)

      @git_working = git_status != :error && git_user_configured?
    end

    def git_user_configured?
      out, status = Open3.capture2e("git config -l")
      status.success? && out.match?(/^user\.name=/) && out.match?(/^user\.email=/)
    end

    # Returns :clean, :dirty, or :error
    def git_status
      return :error unless Dir.exist?(".git")

      output, status = Open3.capture2e("git status --porcelain")
      return :error unless status.success?

      output.empty? ? :clean : :dirty
    end
  end
end
