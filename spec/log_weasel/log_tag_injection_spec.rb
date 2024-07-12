# frozen_string_literal: true

require "rack"
require "logger"
require "active_support"
require "active_support/tagged_logging"

# Note: this is NOT going to test every variation of LogWeasel behavior,
#       but will demonstrate that a LogWeasel id gets passed into the logger
RSpec.describe StitchFix::LogWeasel::LogTagInjection do
  let(:log_weasel_trace_id) { "log_weasel_trace_id1" } # the important one!

  let(:input_body) { '{"abc":"toast"}' }
  let(:env) do
    {
      "HTTP_X_REQUEST_ID" => log_weasel_trace_id, # the important one!
      "rack.input" => StringIO.new(input_body),
      "CONTENT_LENGTH" => input_body.length,
      "CONTENT_TYPE" => "application/json"
    }
  end

  logging_rack_app = Struct.new(:logger) do
    def call(...)
      logger.info "info message"
      [200, {"Content-Type" => "application/json"}, ["response"]]
    end
  end

  let(:app) do
    Rack::Builder.app(logging_rack_app.new(logger)) do
      use StitchFix::LogWeasel::Middleware

      # This middleware would typically be set up by the Railtie
      # with a configuration object that responds to #logger -
      # in this case `@run` is the logging_rack_app passed in to
      # the builder above.
      use StitchFix::LogWeasel::LogTagInjection::Middleware, @run
    end
  end
  let(:log_output) { StringIO.new }
  let(:logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(log_output)) }

  describe "#call" do
    subject(:log_output_json) do
      Rack::MockRequest.new(app).post("http://example.com", env)
      log_output.string
    end

    it "logs the log weasel key and trace id as log_weasel_trace_id" do
      expect(subject).to eq %{[{"trace_origin"=>"log_weasel_trace_id1", "log_weasel_trace_id"=>"log_weasel_trace_id1"}] info message\n}
    end
  end

  context "when using a non-tagged logger" do
    let(:logger) { ::Logger.new(log_output) }

    subject(:log_output_json) do
      Rack::MockRequest.new(app).post("http://example.com", env)
      log_output.string
    end

    it "logs the log weasel key and trace id as log_weasel_trace_id" do
      expect(subject).to match "info message"
      expect(subject).not_to match "trace_origin"
    end
  end

  # context "when disabled" do
  #   before do

  #     StitchFix::LogWeasel.configure do |config|
  #       config.disable_log_tagging = true
  #     end
  #   end

  #   after do
  #     StitchFix::LogWeasel.configure do |config|
  #       config.disable_log_tagging = false
  #     end
  #   end

  #   subject(:log_output_json) do
  #     Rack::MockRequest.new(app).post("http://example.com", env)
  #     log_output.string
  #   end

  #   it "logs the log weasel key and trace id as log_weasel_trace_id" do
  #     expect(subject).to match "info message"
  #     expect(subject).not_to match "trace_origin"
  #   end
  # end
end
