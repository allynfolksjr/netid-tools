module SystemConnect

  private

  def connections
    unless @connections
      @connections = []
    end
    @connections
  end

  def connections=(var)
    @connections = var
  end

  def connect(host,user)
    begin
      Net::SSH.start(host,user,{auth_methods: %w(publickey)})
    rescue
      puts "Connection failed for #{user}@#{host}"
      exit 2
    end

  end

  def threaded_connect(user,*hosts)
    threads = []
    hosts.each do |host|
      threads << Thread.new do
        Thread.current[:name] = host
          connection = SystemSSH.new(host,connect(host,user))
          connections << connection unless connection.connection_object.nil?
      end
    end
    threads.each do |thr|
      if thr.join(4).nil?
        puts "Threaded connect failed for #{user}@#{thr[:name]}"
        exit 2
      end
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
    unless connections.select{ |conn| conn.hostname == host}.empty?
      connections.select{ |conn| conn.hostname == host}.first.connection_object
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
