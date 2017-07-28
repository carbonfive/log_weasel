module StitchFix
  module LogWeasel::Resque

    def self.initialize!
      @@resque ||= setup
    end

    def self.setup
      ::Resque::Worker.send(:include, LogWeasel::Resque::Worker)
      ::Resque::Job.send(:include, LogWeasel::Resque::Job)
      ::Resque.extend(LogWeasel::Resque::ClassMethods)

      key = LogWeasel.config.key ? "#{LogWeasel.config.key}-RESQUE" : "RESQUE"

      ::Resque.after_fork do |job|
        LogWeasel::Resque::Callbacks.after_fork job, key
      end

      ::Resque.before_push do |queue, item|
        LogWeasel::Resque::Callbacks.before_push queue, item, key
      end
      true
    end

    module Callbacks
      def self.after_fork(job, key)
        if job.context && job.context.has_key?('log_weasel_id')
          LogWeasel::Transaction.id = job.context['log_weasel_id']
        else
          LogWeasel::Transaction.create key
        end
      end

      def self.before_push(_queue, item, key)
        # Strip out log_weasel_id, if it is present.
        # This is possible if a delayed job (with a log_weasel_id appended to the job arguments)
        # fails, and is later retried from Resque web.
        if item[:args].is_a?(Array)
          log_weasel_payload = item[:args].detect { |arg| arg.is_a?(Hash) && arg.keys.include?("log_weasel_id") }
          if log_weasel_payload
            LogWeasel::Transaction.id = log_weasel_payload["log_weasel_id"]
            item[:args] = item[:args] - [log_weasel_payload]
          end
        end

        item['context'] = {'log_weasel_id' => (LogWeasel::Transaction.id || LogWeasel::Transaction.create(key))}
      end
    end

    module ClassMethods
      def before_push(&block)
        block ? (@before_push = block) : @before_push
      end

      def push(queue, item)
        self.before_push.call(queue, item) if self.before_push
        super
      end
    end

    module Job
      def context
        @payload['context']
      end

      def inspect_with_context
        inspect_without_context.gsub /\)$/, " | #{context.inspect})"
      end

      def self.included(base)
        base.send :alias_method, :inspect_without_context, :inspect
        base.send :alias_method, :inspect, :inspect_with_context
      end
    end

    module Worker
      def log_with_transaction_id(message)
        log_without_transaction_id "#{LogWeasel::Transaction.id} #{message}"
      end

      def self.included(base)
        base.send :alias_method, :log_without_transaction_id, :log
        base.send :alias_method, :log, :log_with_transaction_id
      end
    end
  end
end