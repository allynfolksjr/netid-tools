module SystemConnect

  private

  def connect(host,user)
    Net::SSH.start(host,user,{auth_methods: %w(publickey)})
  end

  def threaded_connect(user,*hosts)
    @connections ||= []
    connection_objects = []
    threads = []
    hosts.each do |host|
      threads << Thread.new do
        @connections << SystemSSH.new(host,connect(host,user))
      end
    end
    threads.each do |thr|
      thr.join
    end
  end


  def run_remote_command(command, host)
    connection = find_connection_for_host(host)
    connection.exec!(command)
  end

  def loop
    connection.loop
  end

  def queue_multithreaded_command(command,host)
    if connection
      connection.exec(command) do |ch, stream, data|
        unless stream == :stderr
          puts data
        end
      end
    else
      puts "No connection found for host: #{host}"
    end
  end

  def find_connection_for_host(host)
    @connections ||= []
    unless @connections.select{ |conn| conn.hostname == host}.empty?
      @connections.select{ |conn| conn.hostname == host}.first.connection_object
    else
      lazy_load_connection_for_host(host)
      find_connection_for_host(host)
    end
  end

  def lazy_load_connection_for_host(host)
    @connections << SystemSSH.new(host,connect(host,system_user))
  end
end


class SystemSSH
  attr_accessor :hostname, :connection_object
  def initialize(hostname, connection_object)
    @hostname = hostname
    @connection_object = connection_object
  end
end
