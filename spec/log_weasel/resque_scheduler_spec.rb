require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe StitchFix::LogWeasel::ResqueScheduler do

  describe ".enqueue" do
    let(:config) do
      {"class"=>"EchoJob", "args"=>["Hello from HelloController", {"log_weasel_id"=>"FOO-WEB-1234"}]}
    end

    before do
      # so jobs aren't enqueued
      expect(Resque::Job).to receive(:create).and_return(true)
    end

    it "calls setup_log_weasel_transaction_id" do
      expect(Resque::Scheduler).to receive(:setup_log_weasel_transaction_id)
      Resque::Scheduler.enqueue(config)
    end

    context "when args is an Array" do
      context "with a log_weasel_id present" do
        it "sets the current Transaction ID to it" do
          expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("FOO-WEB-1234")
          Resque::Scheduler.enqueue(config)
        end

        it "removes it" do
          expect(config["args"]).to eq(["Hello from HelloController", {"log_weasel_id" => "FOO-WEB-1234"}])
          Resque::Scheduler.enqueue(config)
          expect(config["args"]).to eq(["Hello from HelloController"])
        end
      end

      context "without a log_weasel_id" do
        let(:config) do
          {"class" => "EchoJob", "args" => ["Hello from HelloController"]}
        end

        it "doesn't modify args" do
          Resque::Scheduler.enqueue(config)
          expect(config["args"]).to eq(["Hello from HelloController"])
        end
      end
    end

    context "when args is not an Array" do
      let(:config) do
        {"class" => "EchoJob", "args" => "Hello from HelloController"}
      end

      it "sets the current Transaction ID to nil" do
        expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with(nil)
        Resque::Scheduler.enqueue(config)
      end

      it "doesn't modify args" do
        Resque::Scheduler.enqueue(config)
        expect(config["args"]).to eq("Hello from HelloController")
      end
    end
  end

  describe "Env" do
    before do
      ::Resque::Scheduler::Env.send(:include, StitchFix::LogWeasel::ResqueScheduler::Env)
    end
    describe "#setup" do
      it "instruments resque-scheduler with Log Weasel" do
        expect(StitchFix::LogWeasel).to receive(:configure)
        Resque::Scheduler::Env.new({}).setup
      end
    end
  end

  describe "DelayingExtensions" do
    before do
      ::Resque::Scheduler::DelayingExtensions.send(:include, StitchFix::LogWeasel::ResqueScheduler::DelayingExtensions)
      expect(StitchFix::LogWeasel::Transaction).to receive(:id).and_return("12345")
    end

    describe "#job_to_hash_with_queue_and_lid" do
      context "given queue, klass, and args" do
        let(:queue) { "queue" }
        let(:klass) { "SomeJob" }
        let(:args) { ["hello"] }

        it "adds the Log Weasel transaction ID to args" do
          result = Resque.job_to_hash_with_queue(queue, klass, args)
          expect(result[:queue]).to eq(queue)
          expect(result[:class]).to eq(klass)
          expect(result[:args]).to include({"log_weasel_id"=>"12345"})
        end
      end
    end
  end
end