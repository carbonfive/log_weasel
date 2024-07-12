require 'stitch_fix/log_weasel/transaction'
require 'stitch_fix/log_weasel/logger'
require 'stitch_fix/log_weasel/log_tag_injection'
require 'stitch_fix/log_weasel/airbrake'
require 'stitch_fix/log_weasel/middleware'
require 'stitch_fix/log_weasel/resque'
require 'stitch_fix/log_weasel/sidekiq'
require 'stitch_fix/log_weasel/railtie' if defined? ::Rails::Railtie

module StitchFix
  module LogWeasel
    class Config
      attr_accessor :key, :disable_delayed_job_tracing, :debug, :disable_log_tagging

      def disable_delayed_job_tracing?
        @disable_delayed_job_tracing ||
          (defined?(Rails) && Rails.env.test?)
      end

      def debug_logging_enabled?
        @debug || false
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

      if defined? ::Resque
        StitchFix::LogWeasel::Resque.initialize!
      end

      if defined? ::Resque::Scheduler
        require 'stitch_fix/log_weasel/resque_scheduler'
        require 'stitch_fix/log_weasel/monkey_patches'

        StitchFix::LogWeasel::ResqueScheduler.initialize!
      end

      if defined? ::Sidekiq
        StitchFix::LogWeasel::Sidekiq.initialize!
      end
    end
  end
end
