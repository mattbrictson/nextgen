if @variables[:tailwind_puma]
  say_git "Add tailwindcss plugin to puma.rb"
  append_to_file "config/puma.rb", "plugin :tailwindcss\n"
end
