module StitchFix
  module LogWeasel::Pwwka

    def self.initialize!
      ::Pwwka::Logging.send(:include, LogWeasel::Pwwka::Logging)
    end

    module Logging
      def logf_with_transaction_id(format, params)
        logf_without_transaction_id "[#{LogWeasel::Transaction.id}] #{format}", params
      end

      def self.included(base)
        base.send :alias_method, :logf_without_transaction_id, :logf
        base.send :alias_method, :logf, :logf_with_transaction_id
      end
    end
  end
end