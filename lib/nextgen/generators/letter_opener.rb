# frozen_string_literal: true

say_git "Install letter_opener"
install_gem "letter_opener", group: :development

say_git "Configure Action Mailer to use letter_opener"
insert_into_file "config/environments/development.rb", <<-RUBY, after: "raise_delivery_errors = false\n"

  config.action_mailer.delivery_method = :letter_opener
RUBY
