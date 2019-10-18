require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'stitch_fix/log_weasel/resque_scheduler'
require 'stitch_fix/log_weasel/monkey_patches'

describe StitchFix::LogWeasel::ResqueScheduler do

  before do
    StitchFix::LogWeasel.configure do |config|
      config.debug = false
    end
  end

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

        context "when the value of log_weasel_id is null" do
          let(:config) do
            {"class"=>"EchoJob", "args"=>["Hello from HelloController", {"log_weasel_id" => nil}]}
          end

          it "sets the current Transaction ID to it" do
            expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with(nil)
            Resque::Scheduler.enqueue(config)
          end

          it "removes it" do
            expect(config["args"]).to eq(["Hello from HelloController", {"log_weasel_id" => nil}])
            Resque::Scheduler.enqueue(config)
            expect(config["args"]).to eq(["Hello from HelloController"])
          end
        end
      end

      context "debug mode" do
        context "when true" do
          before do
            StitchFix::LogWeasel.configure do |config|
              config.debug = true
            end
          end

          it "logs" do
            expect(Resque::Scheduler).to receive(:puts).with("A log_weasel_id was found in the job payload. Setting the current Transaction id to it.")
            expect(Resque::Scheduler).to receive(:puts).with("Removing the log_weasel_id from the payload.")
            Resque::Scheduler.enqueue(config)
          end
        end

        context "by default" do
          it "doesn't log" do
            expect(Resque::Scheduler).not_to receive(:puts)
            Resque::Scheduler.enqueue(config)
          end
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

      context "in debug mode" do
        before do
          StitchFix::LogWeasel.configure do |config|
            config.debug = true
          end
        end

        it "logs" do
          expect(Resque::Scheduler).to receive(:puts).with("Initializing log weasel transaction ID")
          Resque::Scheduler.enqueue(config)
        end
      end
    end
  end

  describe "Env" do
    describe "#setup" do
      it "calls setup_without_log_weasel" do
        expect_any_instance_of(Resque::Scheduler::Env).to receive(:setup_without_log_weasel)
        Resque::Scheduler::Env.new({}).setup
      end

      it "instruments resque-scheduler with Log Weasel" do
        expect(StitchFix::LogWeasel).to receive(:configure)
        Resque::Scheduler::Env.new({}).setup
      end

      context "debug mode" do
        context "when true" do
          before do
            StitchFix::LogWeasel.configure do |config|
              config.debug = true
            end
          end

          it "logs" do
            expect_any_instance_of(Resque::Scheduler::Env).to receive(:puts).with("initializing Log Weasel")
            Resque::Scheduler::Env.new({}).setup
          end
        end

        context "by default" do
          it "doesn't log" do
            expect_any_instance_of(Resque::Scheduler::Env).not_to receive(:puts)
            Resque::Scheduler::Env.new({}).setup
          end
        end
      end
    end
  end

  describe "DelayingExtensions" do
    before do
      allow(StitchFix::LogWeasel::Transaction).to receive(:id).and_return("12345")
    end

    describe "#job_to_hash_with_queue_and_lid" do
      context "given queue, klass, and args" do
        let(:queue) { "queue" }
        let(:klass) { "SomeJob" }
        let(:args) { ["hello"] }

        context "in test mode" do
          it "does not add the Log Weasel transaction ID to args" do
            result = Resque.job_to_hash_with_queue(queue, klass, args)
            expect(result[:queue]).to eq(queue)
            expect(result[:class]).to eq(klass)
            expect(result[:args]).not_to include({"log_weasel_id"=>"12345"})
          end
        end

        context "in non-test mode" do
          before do
            allow(Rails).to receive(:env).and_return(double(test?: false))
          end

          it "adds the Log Weasel transaction ID to args" do
            result = Resque.job_to_hash_with_queue(queue, klass, args)
            expect(result[:queue]).to eq(queue)
            expect(result[:class]).to eq(klass)
            expect(result[:args]).to include({"log_weasel_id"=>"12345"})
          end

          context "when disable_delayed_job_tracing is true" do
            before do
              StitchFix::LogWeasel.config.disable_delayed_job_tracing = true
            end

            it "does not add the Log Weasel transaction ID to args" do
              result = Resque.job_to_hash_with_queue(queue, klass, args)
              expect(result[:queue]).to eq(queue)
              expect(result[:class]).to eq(klass)
              expect(result[:args]).not_to include({"log_weasel_id"=>"12345"})
            end
          end
        end
      end
    end
  end
end
