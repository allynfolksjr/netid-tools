class CheckMysql
  def self.do(netid, host)
    command = "ps -U #{netid} -u #{netid}"
    result = exec(command,host)
    if result =~ /mysql/
      /port=(?<port>\d+)/ =~ output
      [host,port]
    else
      false
    end
  end
end
