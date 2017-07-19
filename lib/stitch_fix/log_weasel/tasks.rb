# vim:fileencoding=utf-8

require 'resque/tasks'
require 'resque-scheduler'

namespace :resque do
  desc "Adds Log Weasel setup to resque:scheduler setup task"
  task :log_weasel_setup do
    StitchFix::LogWeasel::ResqueScheduler.initialize!
  end
end

Rake::Task['resque:scheduler_setup'].enhance do
  Rake::Task['resque:log_weasel_setup'].invoke
end
