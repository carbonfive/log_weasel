require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
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
  end

end