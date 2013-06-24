require 'net/ssh'
require 'colored'
require './lib/netid-validator'
require './lib/generic-response'

class Netid
  attr_accessor :netid, :system_user

  def initialize(netid,system_user=nil)
    @netid = netid
    @system_user = system_user
  end

  def validate_netid
    NetidValidator.validate_netid(netid)
  end

   def self.validate_netid?(netid)
    NetidValidator.validate_netid(netid).response
  end

  def validate_netid?
    NetidValidator.validate_netid(netid).response
  end

  def check_for_mysql_presence(host)
    Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
      output = ssh.exec!("ps -U #{netid} -u #{netid} u")
      if output =~ /mysql/
        /port=(?<port>\d+)/ =~ output
        [host,port]
      else
        false
      end
    end
  end

  def get_processes(host)
    output = ""
    Net::SSH.start(host,system_user,{auth_methods: %w(publickey)}) do |ssh|
      if /no such user/i =~ ssh.exec!("id #{netid}")
        output = nil
      else
        output = ssh.exec!("ps -f --user=#{netid}").lines
      end
    end
    if output.nil? || output.count == 1
      false
    else
      output
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
  Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
    ssh.exec!("webtype -user #{netid}").chomp.split(" ")
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
