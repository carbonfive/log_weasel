require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StitchFix::LogWeasel::Logger do
  before do
    @stringio = StringIO.new
    @logger   = StitchFix::LogWeasel::Logger.new @stringio
    allow(StitchFix::LogWeasel::Transaction).to receive(:id).and_return('123')
  end

  it "logs transaction id" do
    @logger.info 'message'
    expect(@stringio.string).to match(/ 123 /)
  end
end