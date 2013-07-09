class UnixProcesses < GenericResponse
  attr_accessor :headers, :hostname
  def initialize(hostname)
    @hostname = hostname
    @processes = []
    @headers = nil
  end
end
