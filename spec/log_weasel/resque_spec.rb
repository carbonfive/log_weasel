require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'resque'

describe LogWeasel::Resque do

  before do
    LogWeasel.configure { |config| config.key = "FOO" }
  end
  
  after do
    LogWeasel::Transaction.destroy
  end

  it "pushes with log_weasel_id in context" do
    expect(Resque).to receive(:redis).and_return(double(:sadd => nil, :rpush => nil, :push_to_queue => true))
    expect(Resque).to receive(:encode) do |item|
      expect(item['context']).to_not be_nil
      expect(item['context']).to have_key('log_weasel_id')
      expect(item['context']['log_weasel_id']).to match(/^FOO-RESQUE/)
    end
    Resque.push('queue', {'args' => [1]})
  end

  describe ".after_fork" do
    context "with log_weasel_id" do
      before do
        @job = Resque::Job.new 'queue', {'args' =>[{}], 'context' => {'log_weasel_id' => "123"}}
      end

      it "sets transaction id from args" do
        expect(LogWeasel::Transaction).to receive(:id=).with('123')
        LogWeasel::Resque::Callbacks.after_fork @job, nil
      end
    end

    context "without log_weasel_id" do
      before do
        @job = Resque::Job.new 'queue', {'args' =>[1]}
      end

      it "creates a new log_weasel_id" do
        expect(LogWeasel::Transaction).to receive(:create)
        LogWeasel::Resque::Callbacks.after_fork @job, nil
      end
    end
  end
end