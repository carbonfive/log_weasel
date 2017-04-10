require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pwwka'

describe LogWeasel::Pwwka do

  let(:transaction_id) { "FOO-PWWKA-123" }

  before do
    LogWeasel.configure { |config| config.key = "FOO" }
    LogWeasel::Transaction.stubs(:id).returns(transaction_id)
  end

  after do
    LogWeasel::Transaction.destroy
  end

  let(:pwwka_client) { MockPwwkaTransmitter }

  it "adds transaction id to logf" do
    pwwka_client.expects(:logf_without_transaction_id).with do |format, _|
      expect(format.scan(/#{transaction_id}/)).not_to be_empty
    end
    pwwka_client.logf("Transmitting message %{routing_key} -> %{payload}", {foo: "bar"})
  end

end

class MockPwwkaTransmitter
  extend Pwwka::Logging
end