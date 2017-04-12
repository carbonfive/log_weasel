require 'stitch_fix/log_weasel/transaction'
require 'stitch_fix/log_weasel/logger'
require 'stitch_fix/log_weasel/airbrake'
require 'stitch_fix/log_weasel/middleware'
require 'stitch_fix/log_weasel/resque'
require 'stitch_fix/log_weasel/pwwka'
require 'stitch_fix/log_weasel/railtie' if defined? ::Rails::Railtie

module StitchFix
  module LogWeasel
    class Config
      attr_accessor :key
    end

    def self.config
      @@config ||= Config.new
    end

    def self.configure
      yield self.config

      if defined? ::Airbrake
        class << ::Airbrake
          include StitchFix::LogWeasel::Airbrake
        end
      end

      if defined? ::Pwwka
        StitchFix::LogWeasel::Pwwka.initialize!
      end

      if defined? ::Resque
        StitchFix::LogWeasel::Resque.initialize!
      end

    end
  end
end