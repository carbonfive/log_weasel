class LogWeasel::Middleware
  def initialize(app, options = {})
    @app = app
    @key = options[:key] ? "#{options[:key]}-WEB" : "WEB"
  end

  def call(env)
    LogWeasel::Transaction.create @key
    @app.call(env)
  ensure
    LogWeasel::Transaction.destroy
  end
end