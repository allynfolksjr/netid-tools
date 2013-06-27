require 'spec_helper'
require 'netid-tools'

describe Netid do

  def mock_system_response(*responses)
    responses.each do |response|
      @netid.should_receive(:run_remote_command).and_return(response)
    end
  end

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
    it "responds to #primary_host" do
      @netid.should respond_to :primary_host
      @netid.primary_host.should_not be_nil
    end
    it "responds to #secondary_host" do
      @netid.should respond_to :secondary_host
      @netid.secondary_host.should_not be_nil
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
      mock_system_response(valid_return)
      @netid.check_for_mysql_presence('fake.example.com').should eq ['fake.example.com', 5280]
    end
    it "returns false with no valid result" do
      mock_system_response("")
      @netid.check_for_mysql_presence('fake.example.com').should be_false
    end
  end

  context "#get_processes" do
    it "returns false if a user is not detected" do
      mock_system_response("no such user")
      @netid.get_processes('example.com').should be_false
    end
    it "returns a UnixProcesses object on success" do
      mock_system_response("exists","1\n2\n3")
      @netid.get_processes('example.com').class.should eq UnixProcesses
    end
    it "contains proper headers with successful return" do
      mock_system_response("exists","a b c\n2\n3")
      @netid.get_processes('example.com').headers.should eq %w(a b c)
    end
    it "properly merges commnds with spaces into one array element" do
      mock_system_response("exists","a b c\n1 2 3 4 5 6 7 8 9 command with space\n2")
      @netid.get_processes('example.com').processes.first[9].should eq "command with space"
    end
    it "properly handles commnds without spaces" do
      mock_system_response("exists","a b c\n1 2 3 4 5 6 7 8 9 command_without_space\n2")
      @netid.get_processes('example.com').processes.first[9].should eq "command_without_space"
    end
    it "doesn't contain newlines" do
      mock_system_response("exists","1\n2\n3")
      @netid.get_processes('example.com').processes.select{|s| s =~ /\/n/}.should be_empty
    end
    it "doesn't contain headers in main processes object" do
      mock_system_response("exists","headers pid guid\n1 2 3 4 5 6 7 8 9 command with space\n2")
      return_obj = @netid.get_processes('example.com')
      return_obj.headers.should eq %w(headers pid guid)
      return_obj.processes.should_not include %w(headers pid guid)
    end
    it "has processes which responds to .each" do
      mock_system_response("exists","headers pid guid\n1 2 3 4 5 6 7 8 9 command with space\n2")
      return_obj = @netid.get_processes('example.com')
      return_obj.processes.should respond_to(:each)
    end
  end

  context "#check_for_localhome" do
    it "returns the localhome location upon success" do
      mock_system_response("/ov03/dw21/derp")
      @netid.check_for_localhome.should eq ("/ov03/dw21/derp")
    end
    it "returns false if no result" do
      mock_system_response("user Unknown")
      @netid.check_for_localhome.should be_false
    end
  end

  context "#check_webtype" do
    it "returns array of webtypes upon success" do
      mock_system_response("depts\ncourses")
      @netid.check_webtype.should eq %w(depts courses)
    end
    it "returns empty array if no webtypes found" do
      mock_system_response("")
      @netid.check_webtype.should be_empty
    end
    it "tries alternate host if primary returns no user found" do
      mock_system_response("user Unknown","depts\ncourses")
      @netid.check_webtype.should eq %w(depts courses)
    end
    it "returns empty array if no webtypes found on alternate host" do
      mock_system_response("user Unknown","")
      @netid.check_webtype.should eq %w()
    end

  end

  context "#check_quota" do
    it "returns an object of results on success" do
      # mock_system_response("")
      @netid.check_quota
    end
    it "returns false upon failure" do
    end
    it "return object has and responds to #response" do
    end
    it "will insert 'n/a' into 5th element if blank" do
    end
    it "will not insert 'n/a' into 5th element if length is 7" do
    end
    it "will translate cluster shortnames into full path, if available" do
    end
    it "will fall back to cluster shortnames if full path not found" do
    end
  end
end
