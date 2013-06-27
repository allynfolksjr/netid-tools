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

  context "#validate_netid" do
    it "returns a GenericResponse of true on valid NetID" do
      @netid.validate_netid.response.should eq true
    end
    it "returns a GenericResponse of false on invalid netid" do
      Netid.new('123test').validate_netid.response.should be_false
    end
    it "returns a GenericResponse with error message on invalid netid" do
      Netid.new('123test').validate_netid.error.should eq "Not a valid NetID"
    end
  end

  context "#validate_netid?" do
    it "returns true on valid NetID" do
      @netid.validate_netid?.should be_true
    end
    it "returns false on NetID that starts with number" do
      Netid.new('123test').validate_netid?.should be_false
    end
    it "returns false on NetID that is too long" do
      Netid.new('abcdefghijklmnop').validate_netid?.should be_false
    end
  end

  context "::validate_netid?" do
    it "returns true on valid NetID" do
      Netid.validate_netid?('nikky').should be_true
    end
    it "returns false on invalid NetID" do
      Netid.validate_netid?('123test').should be_false
    end
  end

end
