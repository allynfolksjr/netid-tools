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

  def initialize(options)

    if options[:netid]
      @netid = options[:netid]
    else
      raise "NetID required in options hash."
    end

    @system_user = options[:system_user] || `whoami`.chomp
    @systems = options[:systems] || ["ovid01.u.washington.edu",
     "ovid02.u.washington.edu",
     "ovid03.u.washington.edu",
     "vergil.u.washington.edu"
   ]
   @primary_host = options[:primary_host] || "ovid02.u.washington.edu"
   @secondary_host = options[:secondary_host] || "vergil.u.washington.edu"

   @debug = options[:debug] || false

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
  response = GenericResponse.new
  command = "ps -F -U #{netid} -u #{netid}"
  result = run_remote_command(command,host)
  if result =~ /mysql/
    /port=(?<port>\d+)/ =~ result
    response.response = [host,port.to_i]
    response
  else
    response.response = false
  end
  response
end

  # Experimental feature
  def pre_load_ssh(*hosts)
    threaded_connect(system_user,*hosts)
  end

  def get_processes(host)
    if /no such user/i =~ run_remote_command("id #{netid}",host)
      result = GenericResponse.new
      result.response = false
      result
    else

      command = "ps -o pid,user,cputime,nice,wchan,pcpu,pmem,rss,start_time,cmd --user #{netid}"
      raw_processes = run_remote_command(command,host).lines.map{|l| l.chomp}
      refined_processes = UnixProcesses.new(host)

      refined_processes.headers = raw_processes[0].split
      raw_processes.shift

      refined_processes.response = raw_processes.map do |line|
        line = line.split

        if line.size > 9
          process = line.slice!(9,line.size-9)
          line[9] = process.join(" ")
        end
        line
      end
      if refined_processes.response.empty?
        result = GenericResponse.new
        result.response = false
        result
      else
        refined_processes
      end
    end
  end

  def check_for_localhome
    response = GenericResponse.new
    result = run_remote_command("cpw -poh #{netid}",primary_host)
    if result =~ /Unknown/
      response.response = false
    else
      response.response = result.chomp
    end
    response
  end

  def check_webtype
    response = GenericResponse.new
    command = "webtype -user #{netid}"
    command_result = run_remote_command(command,primary_host).chomp
    if command_result =~ /user/
      response.response = run_remote_command(command,secondary_host).chomp.split
    else
      response.response = command_result.chomp.split
    end
    response.response = false if response.response.empty?
    response
  end


  def check_quota

    command_result = run_remote_command("quota #{netid}",primary_host)

    if command_result =~ /unknown user/
      result = GenericResponse.new
      result.error = "Unknown User #{netid} on #{primary_host}"
      result.response = false
    else
      result = QuotaResponse.new

      command_result = command_result.chomp.split("\n")
      if command_result.first == ""
        command_result.shift(2)
      else
        command_result.shift
      end

      result.headers = process_quota_headers(command_result)
      result.response = command_result.map do |line|
        line = line.split
        line.insert(4, 'n/a') if line.size == 6
        expand_cluster_path(line)
        line
      end
    end
    result
  end

  private
  def remove_extra_processes(processes)
    processes.select do |line|
      line !~ /ps -F --user|ssh(d:|-agent)|bash|zsh/
    end
  end

  def process_quota_headers(quota_results)
    headings = quota_results.first.split
    quota_results.shift
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
      @user_clusters = run_remote_command(command,primary_host).split.map do |line|
        line.chomp
      end
    end
  end
end
