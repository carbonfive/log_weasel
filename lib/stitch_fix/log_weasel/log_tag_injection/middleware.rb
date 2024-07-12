module StitchFix
  module LogWeasel
    module LogTagInjection
      class Middleware
        def initialize(app, config)
          @app = app
          @config = config
        end

        def call(env)
          return @app.call(env) unless @config&.logger.respond_to?(:tagged)

          tags = {
            "trace_origin" => env[::StitchFix::LogWeasel::Middleware::CORRELATION_ID_KEY],
            "log_weasel_trace_id" => env[::StitchFix::LogWeasel::Middleware::REQUEST_ID_KEY]
          }

          @config.logger.tagged(tags) { @app.call(env) }
        end
      end
    end
  end
end
