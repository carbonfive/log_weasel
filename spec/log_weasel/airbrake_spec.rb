require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'airbrake'

describe LogWeasel::Airbrake do
  before do
    LogWeasel.configure {}
    Airbrake.configure {}
    LogWeasel::Transaction.stubs(:id).returns('123')
  end

  it "adds transaction id to parameters with no parameters" do
    Airbrake.expects(:send_notice).with do |notice|
      notice.parameters.should have_key('log_weasel_id')
    end
    Airbrake.notify(RuntimeError.new('failure'))
  end

end