require 'log_weasel/transaction'
require 'log_weasel/buffered_logger'
require 'log_weasel/hoptoad_notifier'
require 'log_weasel/middleware'
require 'log_weasel/resque'

class << ::HoptoadNotifier
  include LogWeasel::HoptoadNotifier;
end if defined? ::HoptoadNotifier