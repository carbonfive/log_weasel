require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pwwka'

describe StitchFix::LogWeasel::Pwwka do

  let(:transaction_id) { "FOO-PWWKA-123" }

  before do
    StitchFix::LogWeasel.configure { |config| config.key = "FOO" }
    allow(StitchFix::LogWeasel::Transaction).to receive(:id).and_return(transaction_id)
  end

  after do
    StitchFix::LogWeasel::Transaction.destroy
  end

  let(:pwwka_client) { MockPwwkaTransmitter }

  it "adds transaction id to logf" do
    expect(pwwka_client).to receive(:logf_without_transaction_id) do |format, _|
      expect(format.scan(/#{transaction_id}/)).not_to be_empty
    end
    pwwka_client.logf("Transmitting message %{routing_key} -> %{payload}", {foo: "bar"})
  end

  describe ".enhance_message_handler" do
    let(:delivery_info) { {:exchange=>"stitchfix-topics-development", :routing_key=>"sf.hello.event"} }
    let(:properties) { {:content_type=>"application/json; version=1", :correlation_id=>"HELLBLAZER-12345"} }
    let(:payload) { {} }

    before(:all) { StitchFix::LogWeasel::Pwwka.enhance_message_handler(FakeHandler) }

    it "calls handle_without_log_weasel" do
      expect(FakeHandler).to receive(:handle_without_log_weasel)
      FakeHandler.handle!(delivery_info, properties, payload)
    end

    context "when correlation_id is set in the message headers" do
      it "sets Log Weasel Transaction ID to it" do
        expect(StitchFix::LogWeasel::Transaction).to receive(:id=).with("HELLBLAZER-12345")
        FakeHandler.handle!(delivery_info, properties, payload)
      end
    end

    context "when correlation_id is not present" do
      let(:properties) { {:content_type=>"application/json; version=1"} }
      it "does not set the Log Weasel Transaction ID" do
        expect(StitchFix::LogWeasel::Transaction).to_not receive(:id=)
        FakeHandler.handle!(delivery_info, properties, payload)
      end
    end
  end

end

class MockPwwkaTransmitter
  extend Pwwka::Logging
end

class FakeHandler
  def self.handle!(delivery_info, properties, payload)
    # do nothing
  end
end