require 'base64'
require 'openssl'
require 'time'
require 'typhoeus'
require 'crack'
require 'uri'
require 'cgi'

module AWS
  
  include Typhoeus
  include Crack
  
  # AWS time xml format: YYYY-MM-DDThh:mm:ssZ
  def time_xml
    Time.now.utc.xmlschema
  end
  
  def http_get_xml(host, path, request_params)
    path = path == "/" ? path : path + "/"
    req = path + "?" + request_params
    puts "THE REQUEST IS ---------------------- " + req.inspect
    res = Request.get(@host + req)
    XML.parse res.body
  end
end