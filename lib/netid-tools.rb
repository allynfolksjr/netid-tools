require 'net/ssh'
require 'colored'

class Netid
  attr_accessor :netid, :system_user

  def initialize(netid,system_user=nil)
    @netid = netid
    @system_user = system_user
  end

  def self.validate_netid?(netid)
    if netid.to_s.length > 8 || netid !~ /^[a-zA-Z][\w-]{0,7}$/
      false
    else
      true
    end
  end

  def validate_netid?(netid)
    Netid.validate_netid?(netid)
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
      result.each_with_index do |line,index|
        if index == 0 || index == 1
          puts line
          next
        end
        line_components = line.squeeze(" ").split(" ")
        if line_components[1].to_f > line_components[2].to_f
          puts "#{line.bold.red}"
        elsif line_components[4] =~ /day/i || line_components[4].to_i > line_components[5].to_i
          puts line.bold.red+'\n'
        else
          puts line
        end
      end
    end
  end
end
