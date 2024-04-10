copy_file "config/environments/staging.rb"

%w[config/cable.yml config/database.yml].each do |file|
  next unless File.exist?(file)

  config_yml = File.read(file)
  config_yml.sub!(/^production:\n(  .*\n)+/) do |match|
    match + "\n" + match.gsub("production", "staging")
  end
  File.write(file, config_yml)
end
