say_git "Install solid_queue as ActiveJob's backend"
install_gem "solid_queue", version: "~> 0.2"

say_git "Add a solid_queue entry to the Procfile"
if @variables[:solid_queue_puma]
  append_to_file "config/puma.rb", "plugin :solid_queue\n"
else
  append_to_file "Procfile", "worker: bundle exec rake solid_queue:start\n"
end

say_git "Configure Active Job to use the solid_queue adapter"
uncomment_lines "config/environments/production.rb", /config\.active_job/
gsub_file "config/environments/production.rb",
  /active_job\.queue_adapter\s*=\s*:.+/,
  "active_job.queue_adapter = :solid_queue"
uncomment_lines "config/environments/development.rb", /config\.active_job/
gsub_file "config/environments/production.rb",
  /active_job\.queue_adapter\s*=\s*:.+/,
  "active_job.queue_adapter = :solid_queue"
copy_file "config/solid_queue.yml"

say_git "Add the SolidQueue migrations"
system "rails", "solid_queue:install:migrations", exception: true

unless @variables[:api]
  say_git "Mount the SolidQueue web console at /jobs"
  install_gem "mission_control-jobs"
  route "# See [https://github.com/basecamp/mission_control-jobs#authentication-and-base-controller-class]"
  route '# MissionControl::Jobs.base_controller_class = "AdminController"'
  route 'mount MissionControl::Jobs::Engine, at: "/jobs"'
end
