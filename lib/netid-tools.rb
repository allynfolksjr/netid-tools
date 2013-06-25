require 'net/ssh'
require 'colored'
require './lib/netid-validator'
require './lib/check-mysql'
require './lib/system-connect'

require './lib/generic-response'
require './lib/system-connect'

class Netid
  include SystemConnect

  attr_accessor :netid, :system_user, :systems

  def initialize(netid,system_user=nil,systems=nil)
    @netid = netid
    @system_user = system_user || `whoami`.chomp
    @systems = systems || ["ovid01.u.washington.edu",
      "ovid02.u.washington.edu",
      "ovid03.u.washington.edu",
      "vergil.u.washington.edu"
    ]
  end

  def validate_netid
    NetidValidator.do(netid)
  end

  def self.validate_netid?(netid)
    NetidValidator.do(netid).response
  end

  def validate_netid?
    NetidValidator.do(netid).response
  end

  def check_for_mysql_presence(host)
    command = "ps -F -U #{netid} -u #{netid}"
    result = run_remote_command(command,host)
    if result =~ /mysql/
      /port=(?<port>\d+)/ =~ result
      [host,port]
    else
      false
    end
  end

  def get_processes(host)
    result = ""
    if /no such user/i =~ run_remote_command("id #{netid}",host)
      result = nil
    else
      result = run_remote_command("ps -F --user=#{netid}",host).lines
    end
    if result.nil? || result.count == 1
      false
    else
      result
    end

  end

  def check_for_localhome
    host = 'ovid02.u.washington.edu'
    Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
      output = ssh.exec!("cpw -poh #{netid}")
      if output =~ /Unknown/
        false
      else
       output.chomp
     end
   end
 end

 def check_webtype
  host = 'ovid02.u.washington.edu'
  match = []
  Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
    match = ssh.exec!("webtype -user #{netid}").chomp.split(" ")
  end
  if match[0] == "user"
    host = 'vergil.u.washington.edu'
    Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
      match = ssh.exec!("webtype -user #{netid}").chomp.split(" ")
    end
  else
    match
  end
end


def check_quota
  host = 'ovid02.u.washington.edu'
  Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
    result = ssh.exec!("quota #{netid}").chomp
    result = result.split("\n")
    result.delete_at(0) if result.first == ''
    uid = /uid\s(\d+)/.match(result.first)[1].to_i
    result.delete_at(0)
    headings = result.first.split
    result.delete_at(0)
    results = []
    results << headings
    result.each do |line|
      line = line.split
      line.insert(4, 'n/a') if line.size == 6
      results << line
    end
    results
        # line_components = line.squeeze(" ").split(" ")
        # if line_components[1].to_f > line_components[2].to_f
        #   puts "#{line.bold.red}"
        # elsif line_components[4] =~ /day/i || line_components[4].to_i > line_components[5].to_i
        #   puts line.bold.red+'\n'
        # else
        #   puts line
        # end
      # end
    end
  end
end
