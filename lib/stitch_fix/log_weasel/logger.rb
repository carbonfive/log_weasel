require 'logger'

module StitchFix
  class LogWeasel::Logger < ::Logger
    if defined?(Rails)
      # include LoggerSilence for Rails versions >= 5
      requirement = Gem::Requirement.new('>= 5.0.0')
      version = Gem.loaded_specs['rails'].version
      if requirement.satisfied_by?(version)
        include LoggerSilence
      end
    end

    def add(severity, message = nil, progname = nil, &block)
      super(severity, "[#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}] #{LogWeasel::Transaction.id} #$$ #{format_severity(severity)} #{message}", progname, &block)
    end

    private
    # Severity label for logging. (max 5 char)
    SEV_LABEL = %w(DEBUG INFO WARN ERROR FATAL ANY)

    def format_severity(severity)
      SEV_LABEL[severity] || 'ANY'
    end
  end
end
