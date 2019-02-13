require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'resque'

describe StitchFix::LogWeasel::Resque do

  after do
    StitchFix::LogWeasel::Transaction.destroy
  end

  it "pushes with log_weasel_id in context" do
    expect(Resque).to receive(:redis).and_return(double(:sadd => nil, :rpush => nil, :push_to_queue => true))
    expect(Resque).to receive(:encode) do |item|
      expect(item['context']).to_not be_nil
      expect(item['context']).to have_key('log_weasel_id')
      expect(item['context']['log_weasel_id']).to match(/-COMBUSTION-RESQUE$/)
    end
    Resque.push('queue', {'args' => [1]})
  end

  describe ".after_fork" do
    context "with log_weasel_id" do
      before do
        @job = Resque::Job.new 'queue', {'args' =>[{}], 'context' => {'log_weasel_id' => "123"}}
      end

      it "sets transaction id from args" do
        expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with('123')
        StitchFix::LogWeasel::Resque::Callbacks.after_fork @job, nil
      end
    end

    context "without log_weasel_id" do
      before do
        @job = Resque::Job.new 'queue', {'args' =>[1]}
      end

      it "creates a new log_weasel_id" do
        expect(StitchFix::LogWeasel::Transaction).to receive(:create)
        StitchFix::LogWeasel::Resque::Callbacks.after_fork @job, nil
      end
    end
  end

  describe ".before_push" do
    context "when a log_weasel_id is present in the job args" do
      let(:item) { {args: ["foo", {"log_weasel_id" => "blah"}]}}

      it "sets the LogWeasel::Transaction.id" do
        expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("blah")
        StitchFix::LogWeasel::Resque::Callbacks.before_push nil, item, "KEY"
      end

      it "removes it and sets context" do
        StitchFix::LogWeasel::Resque::Callbacks.before_push nil, item, "KEY"
        expect(item[:args]).to eq(["foo"])
        expect(item["context"].keys).to include("log_weasel_id")
      end
    end

    context "when a log_weasel_id key only is present in the job args" do
      let(:item) { {args: ["foo", {"log_weasel_id" => nil}]}}

      it "sets the LogWeasel::Transaction.id" do
        expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with(nil)
        StitchFix::LogWeasel::Resque::Callbacks.before_push nil, item, "KEY"
      end

      it "removes it and sets context" do
        StitchFix::LogWeasel::Resque::Callbacks.before_push nil, item, "KEY"
        expect(item[:args]).to eq(["foo"])
        expect(item["context"].keys).to include("log_weasel_id")
      end
    end

    context "when a log_weasel_id is NOT present in the job args" do
      let(:item) { {args: ["foo"]}}

      it "only sets the context" do
        StitchFix::LogWeasel::Resque::Callbacks.before_push nil, item, "KEY"
        expect(item[:args]).to eq(["foo"])
        expect(item["context"].keys).to include("log_weasel_id")
      end
    end
  end
end
