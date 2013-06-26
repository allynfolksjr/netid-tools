require 'net/ssh'
require 'colored'
require 'netid-validator'
require 'system-connect'
require 'generic-response'

class Netid
  include SystemConnect

  attr_accessor :netid, :system_user, :systems, :single_host, :user_clusters

  def initialize(netid,system_user=nil,systems=nil,single_host=nil)
    @netid = netid
    @system_user = system_user || `whoami`.chomp
    @systems = systems || ["ovid01.u.washington.edu",
                           "ovid02.u.washington.edu",
                           "ovid03.u.washington.edu",
                           "vergil.u.washington.edu"
                           ]
    @single_host = single_host || "ovid02.u.washington.edu"
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
    if /no such user/i =~ run_remote_command("id #{netid}",host)
      result = nil
    else
      result = run_remote_command("ps -F --user=#{netid}",host).lines.map{|l| l.chomp}
      result = remove_extra_processes(result)
    end
    if result.nil? || result.count == 1
      false
    else
      result
    end
  end

  def check_for_localhome
    result = run_remote_command("cpw -poh #{netid}",single_host)
    if result =~ /Unknown/
      false
    else
      result.chomp
    end
  end

  def check_webtype
    result = []
    command = "webtype -user #{netid}"
    result = run_remote_command(command,single_host).chomp.split
    if result[0] == "user"
      result = run_remote_command(command,host).chomp.split(" ")
    else
      result
    end
  end


  def check_quota
    result = run_remote_command("quota #{netid}",single_host)
    result = result.chomp.split("\n")
    result.delete_at(0) if result.first == ''
    uid = /uid\s(\d+)/.match(result.first)[1].to_i
    result.delete_at(0)

    headings = process_quota_headers(result)

    results = []
    results << headings
    result.each do |line|
      line = line.split
      line.insert(4, 'n/a') if line.size == 6

      expand_cluster_path(line)

      results << line
    end
    results
  end

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
      if user_clusters
        user_clusters
      else
        command = "gpw -D #{netid} | sed '1d' | sed 'N;$!P;$!D;$d' | sort | uniq"
        run_remote_command(command,single_host).split("\n").map do |line|
          line.chomp
        end
      end
    end
end
