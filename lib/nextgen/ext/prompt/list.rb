# frozen_string_literal: true

require "tty-prompt"
require "tty-screen"

module Nextgen::Ext
  module Prompt::List
    def initialize(...)
      super
      @per_page ||= [TTY::Prompt::Paginator::DEFAULT_PAGE_SIZE, TTY::Screen.height.to_i - 3].max
    end
  end
end

TTY::Prompt::List.prepend(Nextgen::Ext::Prompt::List)
