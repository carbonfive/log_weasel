require 'rails'

class LogWeasel::Railtie < Rails::Railtie
  config.log_weasel = ActiveSupport::OrderedOptions.new # enable namespaced configuration in Rails environments

  initializer "log_weasel.configure" do |app|
    LogWeasel.configure do |config|
      config.key = app.config.log_weasel[:key] || self.class.app_name
    end

    app.config.middleware.insert_before "::Rails::Rack::Logger", "LogWeasel::Middleware"
  end

  private

  def self.app_name
    ::Rails.application.class.to_s.split("::").first
  end
end