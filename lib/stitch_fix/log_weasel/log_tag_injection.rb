module StitchFix
  module LogWeasel
    module LogTagInjection
    end
  end
end

require "stitch_fix/log_weasel/log_tag_injection/middleware"

require "stitch_fix/log_weasel/log_tag_injection/railtie" if defined? ::Rails::Railtie
