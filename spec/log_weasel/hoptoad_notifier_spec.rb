require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'hoptoad_notifier'
require 'log_weasel/hoptoad_notifier'

describe LogWeasel::HoptoadNotifier do
  before do
    class << ::HoptoadNotifier
      include LogWeasel::HoptoadNotifier;
    end if defined? ::HoptoadNotifier

    HoptoadNotifier.configure {}
    LogWeasel::Transaction.stubs(:id).returns('123')
  end

  it "adds transaction id to parameters with no parameters" do
    HoptoadNotifier.expects(:send_notice).with do |notice|
      notice.parameters.should have_key('log_weasel_id')
    end
    HoptoadNotifier.notify(RuntimeError.new('failure'))
  end

end