class UnixProcesses
  attr_accessor :headers, :hostname, :processes
  def initialize(hostname)
    @hostname = hostname
    @processes = []
    @headers = nil
  end
end
