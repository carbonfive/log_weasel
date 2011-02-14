require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'active_support'

describe LogWeasel::Transaction do

  describe ".id" do

    it "is nil if not created" do
      LogWeasel::Transaction.id.should be_nil
    end

  end

  describe ".id=" do
    before do
      LogWeasel::Transaction.id = "1234"
    end

    it "sets the id" do
      LogWeasel::Transaction.id.should == "1234"
    end

  end

  describe ".create" do
    before do
      SecureRandom.stubs(:hex).returns('94b2')
    end

    it 'creates a transaction id with no key' do
      id = LogWeasel::Transaction.create
      id.should == '94b2'
    end

    it 'creates a transaction id with a key' do
      id = LogWeasel::Transaction.create 'KEY'
      id.should == 'KEY-94b2'
      LogWeasel::Transaction.id.should == id
    end

  end

  describe ".destroy" do
    before do
      LogWeasel::Transaction.create
    end

    it "removes transaction id" do
      LogWeasel::Transaction.destroy
      LogWeasel::Transaction.id.should be_nil
    end
  end
end