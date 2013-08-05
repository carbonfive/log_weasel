require 'log_weasel/transaction'
require 'log_weasel/buffered_logger'
require 'log_weasel/airbrake'
require 'log_weasel/middleware'
require 'log_weasel/resque'
require 'log_weasel/railtie' if defined? ::Rails::Railtie


module LogWeasel
  class Config
    attr_accessor :key
  end

  def self.config
    @@config ||= Config.new
  end

  def self.configure
    yield self.config

    if defined? ::Airbrake
      class << ::Airbrake
        include LogWeasel::Airbrake;
      end
    end

    if defined? ::Resque
      LogWeasel::Resque.initialize!
    end

  end
end

#Rails.application.class.to_s.split("::").first