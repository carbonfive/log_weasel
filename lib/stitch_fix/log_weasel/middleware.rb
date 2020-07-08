# frozen_string_literal: true

module StitchFix
  class LogWeasel::Middleware
    KEY_HEADER = 'X_LOGWEASEL_KEY'
    CORRELATION_ID_KEY = "HTTP_X_CORRELATION_ID"
    REQUEST_ID_KEY = "HTTP_X_REQUEST_ID"
    STITCHFIX_REQUEST_ID_KEY = "HTTP_STITCHFIX_REQUEST_ID"
    PARAMS_KEY = "logweasel_id"

    def initialize(app, options = {})
      @app = app
      @key = LogWeasel.config.key ? "#{LogWeasel.config.key}-WEB" : "WEB"
    end

    # Future: Maybe add X-Amzn-Trace-Id request header for tracing through load balancer
    # (http://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-request-tracing.html)
    def call(env)
      x_correlation_id = env.fetch(REQUEST_ID_KEY, nil) ||
        env.fetch(CORRELATION_ID_KEY, nil) ||
        env.fetch(STITCHFIX_REQUEST_ID_KEY, nil) ||
        log_weasel_id_from_params(env)

      if x_correlation_id
        LogWeasel::Transaction.id = x_correlation_id
      else
        log_weasel_key = env.fetch("HTTP_#{KEY_HEADER}", @key)
        LogWeasel::Transaction.create(log_weasel_key)
      end

      env[CORRELATION_ID_KEY] = LogWeasel::Transaction.id
      env[REQUEST_ID_KEY] = LogWeasel::Transaction.id

      @app.call(env)
    ensure
      LogWeasel::Transaction.destroy
    end

    private

    def log_weasel_id_from_params(env)
      return unless ENV.fetch('LOG_WEASEL_FROM_PARAMS', nil)

      req = Rack::Request.new(env)
      req.params.fetch(PARAMS_KEY, nil)
    end
  end
end
