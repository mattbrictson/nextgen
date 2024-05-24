# frozen_string_literal: true

require "tty-prompt"

module Nextgen::Ext
  module Prompt::Multilist
    private

    def selected_names
      return "" unless @done
      return super if @selected.size < 3

      @selected.first.name + " + #{@selected.size - 1} more"
    end
  end
end

TTY::Prompt::MultiList.prepend(Nextgen::Ext::Prompt::Multilist)
