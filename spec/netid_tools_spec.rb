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
    it "requires a NetID to be initialized" do
      expect do
        Netid.new
      end.to raise_error
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

  context "#check_for_mysql_presence" do
    it "returns array with host and port on valid return" do
      valid_return = "nikky    10167  0.0  0.0 271528  2904 ?        SNl   2012
      0:02 /da23/d38/nikky/mysql/bin/mysqld --basedir=/da23/d38/nikky/mysql
      --datadir=/da23/d38/nikky/mysql/data
      --plugin-dir=/da23/d38/nikky/mysql/lib/plugin
      --log-error=/da23/d38/nikky/mysql/data/mysql-bin.err
      --pid-file=/da23/d38/nikky/mysql/data/ovid02.u.washington.edu.pid
      --socket=/da23/d38/nikky/mysql.sock --port=5280"
      @netid.should_receive(:run_remote_command).and_return(valid_return)
      @netid.check_for_mysql_presence('fake.example.com').should eq ['fake.example.com', 5280]
    end
    it "returns false with no valid result" do
      @netid.should_receive(:run_remote_command).and_return("")
      @netid.check_for_mysql_presence('fake.example.com').should be_false
    end
  end

  context "#get_processes" do
    it "returns false if a user is not detected"
    it "returns a UnixProcesses object on success"
    it "contains proper headers with successful return"
    it "properly merges comamnds with spaces into one array element"
    it "doesn't contain newlines"
    it "doesn't contain headers in main processes object"
    it "has processes which responds to .each"
  end

  context "#check_for_localhome" do
    it "returns the localhome location upon success"
    it "returns false if no result"
  end

  context "#check_webtype" do
    it "returns array of webtypes upon success"
    it "returns false if no webtypes found"
    it "tries alternate host if primary returns no user found"
    it "returns array of webtypes on alternate host upon success"
    it "returns false if no webtypes found on alternate host"
  end

  context "#check_quota" do
    it "returns an array of results on success"
    it "has the first line of result be headings"
    it "will insert 'n/a' into 5th element if blank"
    it "will not insert 'n/a' into 5th element if length is 7"
    it "will translate cluster shortnames into full path, if available"
    it "will fall back to cluster shortnames if full path not found"
  end
end
