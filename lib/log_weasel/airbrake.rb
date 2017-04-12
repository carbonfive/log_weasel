module LogWeasel::Airbrake
  def notify_with_transaction_id(exception, opts = {})
    add_transaction_id(opts) if LogWeasel::Transaction.id
    notify_without_transaction_id exception, opts
  end

  def add_transaction_id(opts)
    opts[:parameters]                           ||= {}
    opts[:parameters]['log_weasel_id'] = LogWeasel::Transaction.id
  end

  def self.included(base)
    base.send :alias_method, :notify_without_transaction_id, :notify
    base.send :alias_method, :notify, :notify_with_transaction_id
  end
end