require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pwwka'

describe LogWeasel::Pwwka do

  let(:transaction_id) { "FOO-PWWKA-123" }

  before do
    LogWeasel.configure { |config| config.key = "FOO" }
    allow(LogWeasel::Transaction).to receive(:id).and_return(transaction_id)
  end

  after do
    LogWeasel::Transaction.destroy
  end

  let(:pwwka_client) { MockPwwkaTransmitter }

  it "adds transaction id to logf" do
    expect(pwwka_client).to receive(:logf_without_transaction_id) do |format, _|
      expect(format.scan(/#{transaction_id}/)).not_to be_empty
    end
    pwwka_client.logf("Transmitting message %{routing_key} -> %{payload}", {foo: "bar"})
  end

end

class MockPwwkaTransmitter
  extend Pwwka::Logging
end