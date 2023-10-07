migration_tasks = %w[
  action_mailbox:install:migrations
  action_text:install:migrations
  active_storage:install
]
all_tasks = rails_command("-T", capture: true).scan(/^\S+\s+(\S+)/).flatten
tasks_to_run = migration_tasks & all_tasks
return unless tasks_to_run.any?

tasks_to_run.each { |task| rails_command(task) }
rails_command "db:migrate"
