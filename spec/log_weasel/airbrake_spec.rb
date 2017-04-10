require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'airbrake'

describe LogWeasel::Airbrake do
  before do
    LogWeasel.configure {}
    Airbrake.configure do |c|
      c.project_id = 99999
      c.project_key = "bogus-1234"
    end
    LogWeasel::Transaction.stubs(:id).returns('123')
  end

  it "adds transaction id to parameters with no parameters" do
    Airbrake.expects(:notify_without_transaction_id).with do |_, opts|
      expect(opts[:parameters].keys).to include('log_weasel_id')
    end
    Airbrake.notify(RuntimeError.new('failure'))
  end
end