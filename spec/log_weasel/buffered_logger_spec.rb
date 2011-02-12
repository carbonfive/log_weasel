require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'log_weasel/buffered_logger'

describe LogWeasel::BufferedLogger do
  before do
    @stringio = StringIO.new
    @logger   = LogWeasel::BufferedLogger.new @stringio
    LogWeasel::Transaction.stubs(:id).returns('123')
  end

  it "logs transaction id" do
    @logger.info 'message'
    @stringio.string.should =~ /\[123\]/
  end
end