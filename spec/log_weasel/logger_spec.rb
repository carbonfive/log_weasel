require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LogWeasel::Logger do
  before do
    @stringio = StringIO.new
    @logger   = LogWeasel::Logger.new @stringio
    LogWeasel::Transaction.stubs(:id).returns('123')
  end

  it "logs transaction id" do
    @logger.info 'message'
    expect(@stringio.string).to match(/ 123 /)
  end
end