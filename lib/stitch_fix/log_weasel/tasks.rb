# vim:fileencoding=utf-8

require 'resque/tasks'
require 'resque-scheduler'

namespace :resque do
  desc "Add Log Weasel setup to resque:scheduler setup task"
  task :add_log_weasel_setup do
    StitchFix::LogWeasel::ResqueScheduler.initialize!
  end
end

Rake::Task['resque:scheduler_setup'].enhance do
  Rake::Task['resque:add_log_weasel_setup'].invoke
end
