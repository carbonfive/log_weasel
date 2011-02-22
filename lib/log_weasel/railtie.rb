require 'rails'

class LogWeasel::Railtie < Rails::Railtie
  config.app_middleware.insert_before "::Rails::Rack::Logger", "LogWeasel::Middleware"
end