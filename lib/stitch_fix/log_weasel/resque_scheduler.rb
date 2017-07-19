require 'resque/scheduler/env'

module StitchFix
  module LogWeasel::ResqueScheduler

    def self.initialize!(options = {})
      ::Resque::Scheduler::DelayingExtensions.send(:include, LogWeasel::ResqueScheduler::DelayingExtensions)
      ::Resque::Scheduler::Env.send(:include, LogWeasel::ResqueScheduler::Env)
    end

    module Env
      # To instrument resque:scheduler rake task with Log Weasel
      def setup_with_log_weasel
        setup_without_log_weasel

        puts "initializing Log Weasel"
        require "stitch_fix/log_weasel"
        key = defined?(::Rails::Railtie) ? StitchFix::LogWeasel::Railtie.app_name.upcase : nil
        key ? "#{key}-RESQUE" : "RESQUE"
        StitchFix::LogWeasel.configure { |config| config.key = key }
      end

      def self.included(base)
        base.send :alias_method, :setup_without_log_weasel, :setup
        base.send :alias_method, :setup, :setup_with_log_weasel
      end
    end

    module DelayingExtensions
      # This adds the Log Weasel txn ID to the delayed/scheduled
      # Resque job payloads.
      def job_to_hash_with_queue_and_lid(queue, klass, args)
        args << { "log_weasel_id" => LogWeasel::Transaction.id }
        job_to_hash_with_queue_without_lid(queue, klass, args)
      end

      def self.included(base)
        base.send :alias_method, :job_to_hash_with_queue_without_lid, :job_to_hash_with_queue
        base.send :alias_method, :job_to_hash_with_queue, :job_to_hash_with_queue_and_lid
      end
    end
  end
end