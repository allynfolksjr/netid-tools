class NetidValidator
  def self.validate_netid(netid)
    response = GenericResponse.new
    if netid.to_s.length > 8 || netid !~ /^[a-zA-Z][\w-]{0,7}$/
      response.response = false
      response.error = 'Not a valid NetID'
    else
      response.response = true
    end
    response
  end
end



