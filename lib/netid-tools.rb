require 'net/ssh'
require 'colored'
require 'netid-validator'
require 'system-connect'
require 'generic-response'
require 'unix-processes'
require 'quota-response'

class Netid
  include SystemConnect

  attr_accessor :netid, :system_user, :systems, :primary_host, :secondary_host

  def initialize(netid,system_user=nil,systems=nil,primary_host=nil,secondary_host=nil)
    @netid = netid
    @system_user = system_user || `whoami`.chomp
    @systems = systems || ["ovid01.u.washington.edu",
                           "ovid02.u.washington.edu",
                           "ovid03.u.washington.edu",
                           "vergil.u.washington.edu"
                           ]
    @primary_host = primary_host || "ovid02.u.washington.edu"
    @secondary_host = secondary_host || "vergil.u.washington.edu"
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
      [host,port.to_i]
    else
      false
    end
  end

  def get_processes(host)
    if /no such user/i =~ run_remote_command("id #{netid}",host)
      result = false
    else

      command = "ps -o pid,user,cputime,nice,wchan,pcpu,pmem,rss,start_time,cmd --user #{netid}"
      raw_processes = run_remote_command(command,host).lines.map{|l| l.chomp}
      refined_processes = UnixProcesses.new(host)

      refined_processes.headers = raw_processes[0].split
      raw_processes.delete_at(0)

      refined_processes.processes = raw_processes.map do |line|
        line = line.split

        if line.size > 9
          process = line.slice!(9,line.size-9)
          line[9] = process.join(" ")
        end
        line
      end
      refined_processes
    end


    # if /no such user/i =~ run_remote_command("id #{netid}",host)
    #   result = nil
    # else
    #   result = run_remote_command("ps -F --user=#{netid}",host).lines.map{|l| l.chomp}
    #   result = remove_extra_processes(result)
    # end
    # if result.nil? || result.count == 1
    #   false
    # else
    #   result
    # end
  end

  def check_for_localhome
    result = run_remote_command("cpw -poh #{netid}",primary_host)
    if result =~ /Unknown/
      false
    else
      result.chomp
    end
  end

  def check_webtype
    result = []
    command = "webtype -user #{netid}"
    result = run_remote_command(command,primary_host).chomp.split
    if result[0] == "user"
      result = run_remote_command(command,secondary_host).chomp.split
    else
      result
    end
  end


  def check_quota

    command_result = run_remote_command("quota #{netid}",primary_host)

    if command_result =~ /unknown user/
      result = GenericResponse.new
      result.error = "Unknown User #{netid} on #{primary_host}"
      result.response = false
    else
      result = QuotaResponse.new

      command_result = command_result.chomp.split
      command_result.delete_at(0) if command_result.first? == ""
      command_result.delete_at(0) # remove uid line

      result.headers = process_quota_headers(command_result)

      result.response << command_result.map do |line|
        line = line.split
        line.insert(4, 'n/a') if line.size == 6
      end
    end
    result
  end








    # command_result = command_result.chomp.split("\n")
    # command_result.delete_at(0) if command_result.first == ''
    # # uid = /uid\s(\d+)/.match(command_result.first)[1].to_i
    # command_result.delete_at(0)

    # headings = process_quota_headers(command_result)

    # command = []
    # command << headings
    # command_result.each do |line|
    #   line = line.split
    #   line.insert(4, 'n/a') if line.size == 6

    #   expand_cluster_path(line)

    #   results << line
    # end
    # results
  # end

  private
    def remove_extra_processes(processes)
      processes.select do |line|
        line !~ /ps -F --user|ssh(d:|-agent)|bash|zsh/
      end
    end

    def process_quota_headers(quota_results)
      headings = quota_results.first.split
      quota_results.delete_at(0)
      headings
    end

    def expand_cluster_path(line)
      clusters = get_user_clusters

      asking_cluster_string = line.first

      search = clusters.find_index do |c|
        c =~ /#{asking_cluster_string}/
      end

      line[0] = clusters[search] if search

      line
    end

    def get_user_clusters
      if @user_clusters
        @user_clusters
      else
        command = "gpw -D #{netid} | sed '1d' | sed 'N;$!P;$!D;$d' | sort | uniq"
        @user_clusters = run_remote_command(command,primary_host).map do |line|
          line.chomp
        end
      end
    end

end
