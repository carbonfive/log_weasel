require 'stitch_fix/log_weasel/transaction'
require 'stitch_fix/log_weasel/logger'
require 'stitch_fix/log_weasel/airbrake'
require 'stitch_fix/log_weasel/middleware'
require 'stitch_fix/log_weasel/resque'
require 'stitch_fix/log_weasel/resque_scheduler'
require 'stitch_fix/log_weasel/pwwka'
require 'stitch_fix/log_weasel/monkey_patches'
require 'stitch_fix/log_weasel/railtie' if defined? ::Rails::Railtie

module StitchFix
  module LogWeasel
    class Config
      attr_accessor :key, :disable_delayed_job_tracing

      def disable_delayed_job_tracing?
        @disable_delayed_job_tracing ||
          (defined?(Rails) && Rails.env.test?)
      end
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

      if defined? ::Resque::Scheduler
        StitchFix::LogWeasel::ResqueScheduler.initialize!
      end
    end
  end
end