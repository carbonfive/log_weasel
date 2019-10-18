require 'resque/scheduler/env'

module StitchFix
  module LogWeasel::ResqueScheduler

    def self.initialize!
      @@resque_scheduler ||= setup
    end

    def self.setup
      ::Resque::Scheduler::DelayingExtensions.send(:include, LogWeasel::ResqueScheduler::DelayingExtensions)
      ::Resque::Scheduler::Env.send(:include, LogWeasel::ResqueScheduler::Env)
      true
    end

    module Env
      # To instrument resque:scheduler rake task with Log Weasel
      def setup_with_log_weasel
        puts "initializing Log Weasel" if StitchFix::LogWeasel.config.debug_logging_enabled?
        key = defined?(::Rails::Railtie) ? StitchFix::LogWeasel::Railtie.app_name.upcase : nil
        key ? "#{key}-RESQUE" : "RESQUE"
        StitchFix::LogWeasel.configure { |config| config.key = key }
        setup_without_log_weasel
      end

      def self.included(base)
        base.send :alias_method, :setup_without_log_weasel, :setup
        base.send :alias_method, :setup, :setup_with_log_weasel
      end
    end

    module DelayingExtensions
      # This adds the Log Weasel txn ID to the delayed/scheduled
      # Resque job payloads, except in Rails test env.
      def job_to_hash_with_queue_and_lid(queue, klass, args)
        unless LogWeasel.config.disable_delayed_job_tracing?
          args << {"log_weasel_id" => LogWeasel::Transaction.id}
        end
        job_to_hash_with_queue_without_lid(queue, klass, args)
      end

      def self.included(base)
        base.send :alias_method, :job_to_hash_with_queue_without_lid, :job_to_hash_with_queue
        base.send :alias_method, :job_to_hash_with_queue, :job_to_hash_with_queue_and_lid
      end
    end
  end
end
