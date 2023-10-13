web: bundle exec puma -C config/puma.rb
release: bundle exec rake db:migrate
worker: bundle exec sidekiq -C config/sidekiq.yml
