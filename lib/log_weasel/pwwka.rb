require 'pwwka'

module LogWeasel::Pwwka

  def self.initialize!
    ::Pwwka::Logging.send(:include, LogWeasel::Pwwka::Logging)
    # ::Pwwka::Transmitter.send(:include, LogWeasel::Pwwka::Transmitter)
    # ::Pwwka::Transmitter.extend(LogWeasel::Pwwka::Logging)
  end

  # def send_message!(payload, routing_key)
  #   logf "START Transmitting Message on %{routing_key} -> %{payload}", routing_key: routing_key, payload: payload
  #   channel_connector.topic_exchange.publish(
  #       payload.to_json,
  #       routing_key: routing_key,
  #       persistent:  true)
  #   channel_connector.connection_close
  #   # if it gets this far it has succeeded
  #   logf "END Transmitting Message on %{routing_key} -> %{payload}", routing_key: routing_key, payload: payload
  #   true
  # end

  # module Transmitter
  #   def send_message_with_transaction_id!(payload, routing_key)
  #     p "payload contains: #{payload}"
  #     key = LogWeasel.config.key ? "#{LogWeasel.config.key}-PWWKA" : "PWWKA"
  #     LogWeasel::Transaction.create key
  #     payload['context'] = {'log_weasel_id' => LogWeasel::Transaction.id}
  #     send_message_without_transaction_id! payload, routing_key
  #   end
  #
  #   def self.included(base)
  #     base.send :alias_method, :send_message_without_transaction_id!, :send_message!
  #     base.send :alias_method, :send_message!, :send_message_with_transaction_id!
  #   end
  # end

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