say_git "Install the sidekiq gem in the :production group, with a binstub"
install_gem "sidekiq", version: "~> 7.0", group: :production
binstub "sidekiq"

say_git "Add a sidekiq entry to the Procfile"
append_to_file "Procfile", "worker: bundle exec sidekiq -C config/sidekiq.yml\n"

say_git "Configure Active Job to use the sidekiq adapter in production"
uncomment_lines "config/environments/production.rb", /config\.active_job/
gsub_file "config/environments/production.rb",
  /active_job\.queue_adapter\s*=\s*:.+/,
  "active_job.queue_adapter = :sidekiq"
gsub_file "config/environments/production.rb", " (and separate queues per environment)", ""
gsub_file "config/environments/production.rb",
  /queue_name_prefix = .*$/,
  "queue_name_prefix = nil # Not supported by sidekiq"

say_git "Mount the Sidekiq web console at /sidekiq, secured with basic auth"
copy_file "config/initializers/sidekiq.rb"
route 'mount Sidekiq::Web => "/sidekiq" if defined?(Sidekiq)'

say_git "Allow SIDEKIQ_CONCURRENCY env var to set concurrency"
document_deploy_var "SIDEKIQ_CONCURRENCY", "Number of threads used per Sidekiq process", default: "5"
copy_file "config/sidekiq.yml"

if File.exist?("config/database.yml")
  gsub_file "config/database.yml",
    'ENV.fetch("RAILS_MAX_THREADS") { 5 }',
    '[5, *ENV.values_at("RAILS_MAX_THREADS", "SIDEKIQ_CONCURRENCY")].map(&:to_i).max'
end
