require 'active_support/secure_random'

module LogWeasel
  module Transaction

    def self.create(key = nil)
      Thread.current[:log_weasel_id] = "#{key ? "#{key}_" : ""}#{SecureRandom.hex(10)}"
    end

    def self.destroy
      Thread.current[:log_weasel_id] = nil
    end

    def self.id=(id)
      Thread.current[:log_weasel_id] = id
    end

    def self.id
      Thread.current[:log_weasel_id]
    end
  end
  
end