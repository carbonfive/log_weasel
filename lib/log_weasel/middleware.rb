class LogWeasel::Middleware
  def initialize(app, options = {})
    @app = app
    @key = options[:key] || 'RAILS'
  end

  def call(env)
    LogWeasel::Transaction.create "#{@key}-WEB"
    @app.call(env)
  ensure
    LogWeasel::Transaction.destroy
  end
end