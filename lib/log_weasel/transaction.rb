module LogWeasel
  module Transaction

    def self.create(key = nil)
      Thread.current[:manilla_transaction_id] = "#{key ? "#{key}_" : ""}#{SecureRandom.hex(10)}"
    end

    def self.destroy
      Thread.current[:manilla_transaction_id] = nil
    end

    def self.id=(id)
      Thread.current[:manilla_transaction_id] = id
    end

    def self.id
      Thread.current[:manilla_transaction_id]
    end
  end
  
end