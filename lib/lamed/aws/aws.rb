require 'base64'
require 'openssl'
require 'time'
require 'uri'

module AWS
    
  # AWS time xml format: YYYY-MM-DDThh:mm:ssZ
  def time_xml
    Time.now.utc.xmlschema
  end
  
end