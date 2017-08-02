require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pwwka'
require 'resque'
require 'stitch_fix/log_weasel'

describe StitchFix::LogWeasel do

  describe ".configure" do
    it "stores key" do
      StitchFix::LogWeasel.configure do |config|
        config.key = "KEY"
      end
      expect(StitchFix::LogWeasel.config.key).to eq "KEY"
    end

    it "initializes Log Weasel decorators for defined libraries" do
      expect(StitchFix::LogWeasel::Pwwka).to receive(:initialize!)
      expect(StitchFix::LogWeasel::Resque).to receive(:initialize!)
      expect(StitchFix::LogWeasel::ResqueScheduler).to receive(:initialize!)
      StitchFix::LogWeasel.configure {}
    end
  end

end