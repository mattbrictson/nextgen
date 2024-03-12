say_git "Install solid_queue as ActiveJob's backend"
install_gem "solid_queue", version: "~> 0.2"

if @variables[:solid_queue_puma__no]
  say_git "Add a solid_queue entry to the Procfile"
  append_to_file "Procfile", "worker: bundle exec rake solid_queue:start\n"
else
  say_git "Add solid_queue plugin to puma.rb"
  append_to_file "config/puma.rb", "plugin :solid_queue\n"
end

say_git "Configure Active Job to use the solid_queue adapter"
gsub_file "config/environments/production.rb",
  /(# )?config\.active_job\.queue_adapter\s+=.*/,
  "config.active_job.queue_adapter = :solid_queue"
inject_into_file "config/environments/development.rb",
  "  config.active_job.queue_adapter = :solid_queue\n",
  after: "config.active_job.verbose_enqueue_logs = true\n"
copy_file "config/solid_queue.yml"

say_git "Add the solid_queue migrations"
system "rails", "solid_queue:install:migrations", exception: true

unless @variables[:api]
  say_git "Mount the solid_queue web console at /jobs"
  install_gem "mission_control-jobs"
  route "# See [https://github.com/basecamp/mission_control-jobs#authentication-and-base-controller-class]"
  route '# MissionControl::Jobs.base_controller_class = "AdminController"'
  route 'mount MissionControl::Jobs::Engine, at: "/jobs"'
end
