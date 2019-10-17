require 'resque-scheduler'

module Resque
  module Scheduler
    # Example config:
    # {"class"=>"EchoJob", "args"=>["delayed hello from HelloController", {"log_weasel_id"=>"HELLBLAZER-WEB-27c2d9bb1f3a28474b10"}]}
    def self.enqueue_with_log_weasel(config)
      setup_log_weasel_transaction_id(config)
      enqueue_without_log_weasel(config)
    end

    def self.setup_log_weasel_transaction_id(config)
      if config["args"].is_a?(Array)
        log_weasel_payload = config["args"].detect { |arg| arg.is_a?(Hash) && arg.keys.include?("log_weasel_id") }
        if log_weasel_payload
          puts "A log_weasel_id was found in the job payload. Setting the current Transaction id to it." if StitchFix::LogWeasel.config.debug_logging_enabled?
          StitchFix::LogWeasel::Transaction.id = log_weasel_payload["log_weasel_id"]
          puts "Removing the log_weasel_id from the payload." if StitchFix::LogWeasel.config.debug_logging_enabled?
          config["args"] = config["args"] - [log_weasel_payload]
        end
      else
        puts "Initializing log weasel transaction ID" if StitchFix::LogWeasel.config.debug_logging_enabled?
        StitchFix::LogWeasel::Transaction.id = nil
      end
    end

    singleton_class.send(:alias_method, :enqueue_without_log_weasel, :enqueue)
    singleton_class.send(:alias_method, :enqueue, :enqueue_with_log_weasel)
  end
end
