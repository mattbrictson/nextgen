
unless @variables[:tailwind_puma__no]
  say_git "Add tailwindcss plugin to puma.rb"
  append_to_file "config/puma.rb", %(plugin :tailwindcss if ENV.fetch("RAILS_ENV", "development") == "development"\n)
end
