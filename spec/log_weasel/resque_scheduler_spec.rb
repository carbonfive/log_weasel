require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe StitchFix::LogWeasel::ResqueScheduler do

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