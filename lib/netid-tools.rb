require 'net/ssh'
require 'colored'

class Netid
  # Validate that string is in the form of a valid NetID. eg: 1-8 chars, doesn't start
  # with a number, and no special characters
  def self.validate_netid?(netid)
    if netid.to_s.length > 8 || netid !~ /^[a-zA-Z]\w{0,7}$/
      false
    else
      true
    end
  end

  # Checks to see if MySQL is running on a specified host. Returns array with host, port
  # if present, returns false if not present.
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

  # Returns location of localhome if present
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

  def self.quota_check(user,system_user)
    host = 'ovid02.u.washington.edu'
    Net::SSH.start(host,system_user, {auth_methods: %w( publickey )}) do |ssh|
      result = ssh.exec!("quota #{user}").chomp
      # Split along newlines
      result = result.split("\n")
      # This deletes the first blank line. There be an easier way to do this
      result.delete_at(0) if result.first == ''
      # Go through each line of the result
      result.each_with_index do |line,index|
        # The first two are headers: print and ignore
        if index == 0 || index == 1
          puts line
          next
        end
        # Break the line up into elements
        line_components = line.squeeze(" ").split(" ")
        # Check to see if usage is over quota
        if line_components[1].to_f > line_components[2].to_f
          puts "#{line.bold.red}"
          # If there's a grace period, it shows up in [4], so we account for that
          # and flag if its present
        elsif line_components[4] =~ /day/i || line_components[4].to_i > line_components[5].to_i
          puts line.bold.red+'\n'
        else
          puts line
        end
      end
    end
  end
end
