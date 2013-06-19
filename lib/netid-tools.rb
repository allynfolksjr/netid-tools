require 'net/ssh'
require 'colored'

class Netid
  def self.validate_netid?(netid)
    if netid.to_s.length > 8 || netid !~ /^[a-zA-Z][\w-]{0,7}$/
      false
    else
      true
    end
  end

  def self.check_for_mysql_presence(host,user,system_user)
    Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
      output = ssh.exec!("ps -U #{user} -u #{user} u")
      if output =~ /mysql/
        /port=(?<port>\d+)/ =~ output
        [host,port]
      else
        false
      end
    end
  end

  def self.get_processes(host,user,system_user)
    output = ""
    Net::SSH.start(host,system_user,{auth_methods: %w(publickey)}) do |ssh|
      if /no such user/i =~ ssh.exec!("id #{user}")
        output = nil
      else
        output = ssh.exec!("ps -f --user=#{user}").lines
      end
    end
    if output.nil? || output.count == 1
      false
    else
      output
    end
  end

  def self.check_for_localhome(user,system_user)
    host = 'ovid02.u.washington.edu'
    Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
      output = ssh.exec!("cpw -poh #{user}")
      if output =~ /Unknown/
        false
      else
       output.chomp
     end
   end
 end

 def self.check_webtype(user,system_user)
  host = 'ovid02.u.washington.edu'
  Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
    ssh.exec!("webtype -user #{user}").chomp
  end
end


def self.quota_check(user,system_user)
  host = 'ovid02.u.washington.edu'
  Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
    result = ssh.exec!("quota #{user}").chomp
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
