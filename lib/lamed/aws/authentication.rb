module Aws
  module Authentication
    
    include AWS
    
    AMAZON_ACCESS_KEY_ID = ENV['AMAZON_ACCESS_KEY_ID']
    AMAZON_SECRET_ACCESS_KEY = ENV['AMAZON_SECRET_ACCESS_KEY']
    SIGNATURE_VERSION = '2'
    
    def new_digest
      OpenSSL::Digest::Digest.new('sha256')
    end
    
    def sign(string)
      Base64.encode64(OpenSSL::HMAC.digest(new_digest, aws_secret_access_key, string)).strip
    end
    
    def aws_access_key_id
      AMAZON_ACCESS_KEY_ID
    end
    
    def aws_secret_access_key
      AMAZON_SECRET_ACCESS_KEY
    end
    
    # Escape the nonreserved AWS characters. Use this instead of URI.escape or CGI.escape
    # See String#unpack for hex nibbles: http://ruby-doc.org/core/classes/String.html#M000760
    def aws_escape(string)
      string.to_s.gsub(/([^a-zA-Z0-9._~-]+)/n) { '%' + $1.unpack('H2' * $1.size).join('%').upcase }
    end
    
    def aws_escape_params(params, opts = {})
      request = params.merge(opts)
      request.inject({}) { |h,(k,v)| h[aws_escape(k)] = aws_escape(v);h }
    end
    
    def uri_escape_params(params, opts = {})
      request = params.merge(opts)
      request.inject({}) { |h,(k,v)| h[URI.escape(k.to_s)] = URI.escape(v.to_s);h }
    end
    
    # Create an AWS signature
    # From: http://docs.amazonwebservices.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/
    # String to sign:
    #   HTTPVerb + "\n" +
    #   ValueOfHostHeaderInLowercase + "\n" +
    #   HTTPRequestURI + "\n" +         
    #   CanonicalizedQueryString
    # Calculate an RFC 2104-compliant HMAC with the string you just created, your Secret Access Key as the key.
    # We use SHA256 as the hash algorithm.
    # Do not encode the signature here.  The string will be encoded when it's included in the query string.
    #def aws_signature(httpverb, host, requesturi, params = {})
    #  sorted_params = params.sort.inject({}) { |h,(k,v)| h[k] = v;h }
    #  query_string = aws_escape_params(sorted_params).collect { |k,v| k + '=' + v }.join('&')
    #  string_to_sign = "#{httpverb.to_s.upcase}\n#{host}\n#{requesturi}\n#{query_string}"
    #  puts "STRING TO SIGN is " + string_to_sign.inspect
    #  sign(string_to_sign)
    #end
    def aws_signature(string_to_sign)
      sign(string_to_sign)
    end
    
    def generate_string_to_sign(httpverb, host, uri, params = {})
      verb = httpverb.to_s.upcase
      sorted_params = params.sort.inject({}) { |h,(k,v)| h[k] = v;h }
      query_string = aws_escape_params(sorted_params).collect { |k,v| k + '=' + v }.join('&')
      "#{verb}\n#{host}\n#{uri}\n#{query_string}"
    end
    
    def generate_request(action, params = {})
      request = {
        'Action' => action,
        'SignatureMethod' => 'HmacSHA256',
        'AWSAccessKeyId'  => aws_access_key_id,
        'SignatureVersion' => SIGNATURE_VERSION
      }
      request.merge(default_params).merge(params)
    end
    
    
    def generate_query_string(params, opts = {})
      query_hash = params.merge(opts)
      query_string = URI.escape(query_hash.collect { |k,v| k.to_s + '=' + v.to_s }.join('&'))
      query_string.gsub(/\+/, "%2B")
    end
     
    def generate_query(action, params = {})
      request_hash = generate_request(action, params)
      uri = url_path || "/"
      uri = uri + "/" unless uri == "/"
      string_to_sign = generate_string_to_sign(:get, @host, uri, request_hash)
      signature = aws_signature(string_to_sign)
      generate_query_string(request_hash, 'Signature' => signature)
    end
  end
end