class LogWeasel::Middleware
  def initialize(app, options = {})
    @app = app
    @key = LogWeasel.config.key ? "#{LogWeasel.config.key}-WEB" : "WEB"
  end

  def call(env)
    LogWeasel::Transaction.create @key
    @app.call(env)
  ensure
    LogWeasel::Transaction.destroy
  end
end