class LogWeasel::Middleware
  KEY_HEADER = 'X_LOGWEASEL_KEY'

  def initialize(app, options = {})
    @app = app
    @key = LogWeasel.config.key ? "#{LogWeasel.config.key}-WEB" : "WEB"
  end

  def call(env)
    key = env.fetch("HTTP_#{KEY_HEADER}", @key)
    LogWeasel::Transaction.create key
    @app.call(env)
  ensure
    LogWeasel::Transaction.destroy
  end
end