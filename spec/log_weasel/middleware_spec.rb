require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'stitch_fix/log_weasel'


describe StitchFix::LogWeasel::Middleware do
  let(:app) { double(:call) }

  before do
    expect(app).to receive(:call).with(env)

    StitchFix::LogWeasel.configure do |config|
      config.key = "KEY"
    end
  end

  describe ".call" do
    context "given an env" do
      context "when an StitchFix::LogWeasel::Middleware::CORRELATION_ID_KEY header is present" do
        let(:env) { {StitchFix::LogWeasel::Middleware::CORRELATION_ID_KEY => "1234"} }

        it "sets LogWeasel::Transation.id to the X-Correlation-Id value" do
          expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("1234")
          StitchFix::LogWeasel::Middleware.new(app).call(env)
        end
      end

      context "when an StitchFix::LogWeasel::Middleware::STITCHFIX_REQUEST_ID_KEY header is present" do
        let(:env) { {StitchFix::LogWeasel::Middleware::STITCHFIX_REQUEST_ID_KEY => "1234"} }

        it "sets LogWeasel::Transation.id to the X-Correlation-Id value" do
          expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("1234")
          StitchFix::LogWeasel::Middleware.new(app).call(env)
        end
      end

      context "when an StitchFix::LogWeasel::Middleware::REQUEST_ID_KEY header is present" do
        let(:env) { {StitchFix::LogWeasel::Middleware::REQUEST_ID_KEY => "1234"} }

        it "sets LogWeasel::Transation.id to the X-Request-Id value" do
          expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("1234")
          StitchFix::LogWeasel::Middleware.new(app).call(env)
        end
      end

      context "when both REQUEST_ID_KEY and CORRELATION_ID_KEY headers are present" do
        let(:env) {
          {StitchFix::LogWeasel::Middleware::CORRELATION_ID_KEY => "1234",
           StitchFix::LogWeasel::Middleware::REQUEST_ID_KEY => "5678"}
        }

        it "sets LogWeasel::Transation.id to the X-Request-Id value" do
          expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("5678")
          StitchFix::LogWeasel::Middleware.new(app).call(env)
        end
      end

      context "when neither CORRELATION_ID_KEY nor REQUEST_ID_KEY header is present" do
        let(:env) { {} }

        before do
          allow(StitchFix::LogWeasel::Transaction).to receive(:id).and_return("1234")
        end

        it "creates a new LogWeasel::Transation.id" do
          expect(StitchFix::LogWeasel::Transaction).to receive(:create).with("#{StitchFix::LogWeasel.config.key}-WEB")
          StitchFix::LogWeasel::Middleware.new(app).call(env)
        end

        it "adds a StitchFix::LogWeasel::Middleware::CORRELATION_ID_KEY header" do
          expect(StitchFix::LogWeasel::Transaction).to receive(:create)
            .with("#{StitchFix::LogWeasel.config.key}-WEB")
          expect(env).to receive(:[]=)
            .with(StitchFix::LogWeasel::Middleware::CORRELATION_ID_KEY, "1234")
          expect(env).to receive(:[]=)
            .with(StitchFix::LogWeasel::Middleware::REQUEST_ID_KEY, "1234")

          StitchFix::LogWeasel::Middleware.new(app).call(env)
        end
      end

      context "when the log weasel id is included in the params" do
        let(:env) do
          Rack::MockRequest.env_for("something", params: { logweasel_id: 'foo' })
        end

        context "with the environment variable enabled" do
          it "sets LogWeasel::Transation.id to the header value" do
            allow(ENV).to receive(:fetch).with('LOG_WEASEL_FROM_PARAMS', nil).and_return(true)

            env['HTTP_X_REQUEST_ID'] = 'bar'

            expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("bar")

            StitchFix::LogWeasel::Middleware.new(app).call(env)
          end

          context "a request without the log weasel headers" do
            it "sets LogWeasel::Transation.id to the query string parameter value" do
              allow(ENV).to receive(:fetch).with('LOG_WEASEL_FROM_PARAMS', nil).and_return(true)

              expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("foo")

              StitchFix::LogWeasel::Middleware.new(app).call(env)
            end
          end
        end
      end

      context "when the log weasel id is included in the cookies" do
        let(:env) do
          Rack::MockRequest.env_for("something", "HTTP_COOKIE" => 'logweasel_cookie_trace=cookietrace;')
        end

        context "with the environment variable enabled" do
          it "sets LogWeasel::Transation.id to the header value" do
            allow(ENV).to receive(:fetch).with('LOG_WEASEL_FROM_PARAMS', nil).and_return(nil)
            allow(ENV).to receive(:fetch).with('LOG_WEASEL_FROM_COOKIE', nil).and_return(true)

            env['HTTP_X_REQUEST_ID'] = 'bar'

            expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("bar")

            StitchFix::LogWeasel::Middleware.new(app).call(env)
          end

          context "a request without the log weasel headers" do
            it "sets LogWeasel::Transation.id to the cookie value" do
              allow(ENV).to receive(:fetch).with('LOG_WEASEL_FROM_PARAMS', nil).and_return(nil)
              allow(ENV).to receive(:fetch).with('LOG_WEASEL_FROM_COOKIE', nil).and_return(true)

              expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("cookietrace")

              StitchFix::LogWeasel::Middleware.new(app).call(env)
            end
          end
        end
      end

      context "when the log weasel id is not included in the params" do
        let(:env) do
          Rack::MockRequest.env_for("something", params: { something_else: 'foo' })
        end

        context "with the environment variable enabled" do
          it "does not set the log weasel id from the params" do
            allow(ENV).to receive(:fetch).with('LOG_WEASEL_FROM_PARAMS', nil).and_return(true)

            # Let's pretend its a header...
            env['HTTP_X_REQUEST_ID'] = 'bar'

            expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("bar")

            StitchFix::LogWeasel::Middleware.new(app).call(env)
          end
        end
      end

      context "ensure block" do
        let(:env) { {} }

        it "destroys the current LogWeasel::Transaction.id" do
          expect(StitchFix::LogWeasel::Transaction).to receive(:destroy)
          StitchFix::LogWeasel::Middleware.new(app).call(env)
        end
      end
    end
  end
end
