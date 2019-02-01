# frozen_string_literal: true

module StitchFix
  class LogWeasel::Middleware
    KEY_HEADER = 'X_LOGWEASEL_KEY'
    CORRELATION_ID_KEY = "HTTP_X_CORRELATION_ID"
    REQUEST_ID_KEY = "HTTP_X_REQUEST_ID"

    def initialize(app, options = {})
      @app = app
      @key = LogWeasel.config.key ? "#{LogWeasel.config.key}-WEB" : "WEB"
    end

    # Future: Maybe add X-Amzn-Trace-Id request header for tracing through load balancer
    # (http://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-request-tracing.html)
    def call(env)
      x_correlation_id = env.fetch(REQUEST_ID_KEY,
                                   env.fetch(CORRELATION_ID_KEY,
                                             nil))

      if x_correlation_id
        LogWeasel::Transaction.id = x_correlation_id
      else
        log_weasel_key = env.fetch("HTTP_#{KEY_HEADER}", @key)
        LogWeasel::Transaction.create(log_weasel_key)
        env[CORRELATION_ID_KEY] = LogWeasel::Transaction.id
        env[REQUEST_ID_KEY] = LogWeasel::Transaction.id
      end
      @app.call(env)
    ensure
      LogWeasel::Transaction.destroy
    end
  end
end
