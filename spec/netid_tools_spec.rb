require 'spec_helper'
require 'netid-tools'

describe Netid do
  before do
    @netid = Netid.new('test')
  end
  context "sanity checks" do
    it "responds to #netid" do
      @netid.should respond_to :netid
      @netid.netid.should eq 'test'
    end
    it "responds to #system_user" do
      @netid.should respond_to :system_user
      @netid.system_user.should eq `whoami`.chomp
    end
    it "responds to #systems" do
      @netid.should respond_to :systems
      @netid.systems.should respond_to :size
    end
    it "responds to #single_host" do
      @netid.should respond_to :single_host
      @netid.single_host.should_not be_nil
    end
  end
end
