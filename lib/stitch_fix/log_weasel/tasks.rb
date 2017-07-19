# vim:fileencoding=utf-8

require 'pwwka/tasks'
require 'resque/tasks'
require 'resque-scheduler'

namespace :resque do
  desc "Adds Log Weasel setup to resque:scheduler setup task"
  task :log_weasel_setup do
    StitchFix::LogWeasel::ResqueScheduler.initialize!
  end
end

Rake::Task["resque:scheduler_setup"].enhance do
  Rake::Task["resque:log_weasel_setup"].invoke
end

namespace :message_handler do
  desc "Decorate the message handler class with log weasel methods"
  task :before_receive => :environment do
    raise "HANDLER_KLASS must be set" unless ENV['HANDLER_KLASS']
    handler_klass = ENV["HANDLER_KLASS"].constantize
    StitchFix::LogWeasel::Pwwka.enhance_message_handler(handler_klass)
  end

  task :receive => :before_receive
end