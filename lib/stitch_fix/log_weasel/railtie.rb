require 'rails'

module StitchFix
  class LogWeasel::Railtie < Rails::Railtie
    config.log_weasel = ActiveSupport::OrderedOptions.new # enable namespaced configuration in Rails environments

    initializer "log_weasel.configure" do |app|
      LogWeasel.configure do |config|
        config.key = app.config.log_weasel[:key] || LogWeasel::Railtie.app_name.upcase
      end

      app.config.middleware.insert_before ::ActionDispatch::RequestId, LogWeasel::Middleware

    end

    initializer "stitch_fix.logger.log_weasel.initialize" do |app|
      unless LogWeasel.config.disable_log_tagging
        app.config.middleware.insert_after(
          # ::StitchFix::LogWeasel::Middleware needs to be
          # before ::Rails::Rack::Logger but _we_ want to be after Rails'
          # so that we ensure logs get flushed
          ::Rails::Rack::Logger,
          ::StitchFix::LogWeasel::LogTagInjection::Middleware,
          app.config
        )
      end
    end

    private

    def self.app_name
      ::Rails.application.class.to_s.split("::").first
    end
  end
end
