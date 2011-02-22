require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'resque'
require 'log_weasel'

describe LogWeasel do

  describe ".configure" do
    it "stores key" do
      LogWeasel.configure do |config|
        config.key = "KEY"
      end
      LogWeasel.config.key.should == "KEY"
    end
  end

end