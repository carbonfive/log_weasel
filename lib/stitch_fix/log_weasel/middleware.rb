module StitchFix
  class LogWeasel::Middleware
    KEY_HEADER = 'X_LOGWEASEL_KEY'

    def initialize(app, options = {})
      @app = app
      @key = LogWeasel.config.key ? "#{LogWeasel.config.key}-WEB" : "WEB"
    end

    # Future: Maybe add X-Amzn-Trace-Id request header for tracing through load balancer
    # (http://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-request-tracing.html)
    def call(env)
      x_request_id = env.fetch("HTTP_X_REQUEST_ID", nil)

      if x_request_id
        LogWeasel::Transaction.id = x_request_id
      else
        log_weasel_key = env.fetch("HTTP_#{KEY_HEADER}", @key)
        LogWeasel::Transaction.create(log_weasel_key)
        env["HTTP_X_REQUEST_ID"] = LogWeasel::Transaction.id
      end
      @app.call(env)
    ensure
      LogWeasel::Transaction.destroy
    end
  end
end