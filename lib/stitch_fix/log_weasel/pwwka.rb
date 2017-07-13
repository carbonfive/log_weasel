module StitchFix
  module LogWeasel::Pwwka

    def self.initialize!
      ::Pwwka::Logging.send(:include, LogWeasel::Pwwka::Logging)
      ::Pwwka::PublishOptions.send(:include, LogWeasel::Pwwka::PublishOptions)
      # ::Pwwka::Transmitter.send(:include, LogWeasel::Pwwka::InstanceMethods)
    end

    module Logging
      def logf_with_transaction_id(format, params)
        puts "from logf_with_transaction_id params: #{params}"
        logf_without_transaction_id "[#{LogWeasel::Transaction.id}] #{format}", params
      end

      def self.included(base)
        base.send :alias_method, :logf_without_transaction_id, :logf
        base.send :alias_method, :logf, :logf_with_transaction_id
      end
    end

    module PublishOptions
      def to_h_with_correlation_id
        puts "PublishOptions#to_h_with_correlation_id"
        key = LogWeasel.config.key ? "#{LogWeasel.config.key}-PWWKA" : "PWWKA"
        to_h_without_correlation_id.merge(correlation_id: LogWeasel::Transaction.id || LogWeasel::Transaction.create(key))
      end

      def self.included(base)
        base.send :alias_method, :to_h_without_correlation_id, :to_h
        base.send :alias_method, :to_h, :to_h_with_correlation_id
      end
    end
  end
end