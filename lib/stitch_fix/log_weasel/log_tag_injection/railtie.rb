require "stitch_fix/log_weasel/middleware"

module StitchFix
  module LogWeasel
    module LogTagInjection
      class Railtie < ::Rails::Railtie
        # add a stitchfix logger configuration area if necessary
        config.stitchfix_logger = ::ActiveSupport::OrderedOptions.new unless config.respond_to?(:stitchfix_logger)

        initializer "stitch_fix.logger.log_weasel.initialize" do |app|
          unless app.config.stitchfix_logger.disable_railtie
            app.config.middleware.insert_after(
              # ::StitchFix::LogWeasel::Middleware needs to be
              # before ::Rails::Rack::Logger but _we_ want to be after Rails'
              # so that we ensure logs get flushed
              ::Rails::Rack::Logger,
              ::StitchFix::LogWeasel::LogTagInjection::Middleware,
              app.config.stitchfix_logger
            )
          end
        end

        config.to_prepare do
          ::Rails.application.config.stitchfix_logger.logger ||= ::Rails.logger
        end
      end
    end
  end
end
