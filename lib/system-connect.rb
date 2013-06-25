module SystemConnect

  # def initialize_ssh_connections
  #   connections = []
  #   systems.each do |host|
  #     puts "Attempting connection for #{system_user}@#{host}"
  #     connections << SystemSSH.new(host,connect(host, system_user))
  #     puts "Connection successful for #{host}"
  #   end
  #   @connections = connections
  # end

  def connect(host,user)
    Net::SSH.start(host,user,{auth_methods: %w(publickey)})
  end

  def run_remote_command(command, host)
    connection = find_connection_for_host(host)
    connection.exec!(command)
    # if connection
    #   connection.exec(command) do |ch, stream, data|
    #     unless stream == :stderr
    #       puts data
    #     end
    #   end
    # else
    #   puts "No connection found for host: #{host}"
    # end
  end

  def loop
    connection.loop
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
