require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'resque'
require 'log_weasel/resque'

describe LogWeasel::Resque do

  before do
    LogWeasel::Resque.initialize! :key => 'FOO'
  end
  
  after do
    LogWeasel::Transaction.destroy
  end

  it "pushes with log_weasel_id in context" do
    Resque.stubs(:redis).returns(stub(:sadd => nil, :rpush => nil))
    Resque.expects(:encode).with do |item|
      item['context'].should_not be_nil
      item['context'].should have_key('log_weasel_id')
      item['context']['log_weasel_id'].should =~ /^FOO-RESQUE/
    end
    Resque.push('queue', {'args' => [1]})
  end

  describe ".after_fork" do
    context "with log_weasel_id" do
      before do
        @job = Resque::Job.new 'queue', {'args' =>[{}], 'context' => {'log_weasel_id' => "123"}}
      end

      it "sets transaction id from args" do
        LogWeasel::Transaction.expects(:id=).with('123')
        LogWeasel::Resque::Callbacks.after_fork @job, nil
      end
    end

    context "without log_weasel_id" do
      before do
        @job = Resque::Job.new 'queue', {'args' =>[1]}
      end

      it "creates a new log_weasel_id" do
        LogWeasel::Transaction.expects(:create)
        LogWeasel::Resque::Callbacks.after_fork @job, nil
      end
    end
  end
end