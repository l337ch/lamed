require 'mustache'

module Lamed
  class Controller < Mustache
    
    include Rack
    include Lamed::Helper
    #extend Lamed::Helper
    include Lamed::Model
      
    def self_path(str)
      @self_path = str
    end
    
    def req_params
      env
    end
    
    def content_type(content_type)
      req_params[:content_type] = content_type
    end
    
    def user_agent
      req_params['HTTP_USER_AGENT']
    end
    
    # Find the uri's as and array of symbols from the request_path
    def uri(request_path)
      begin
        uri = (request_path.split("/").collect {|r| r.downcase.intern unless r.empty?}).compact
      rescue NoMethodError
        uri = Array.new
      end
      @uri = uri
    end
    
    # Build param symbols from the query string
    def params(query_string)
      begin
        params_prime = query_string.split('&').inject({}) { |h,(k,v)|
          values = k.split('=')
          # Drop any query params that have blank values
          h[values[0].downcase.intern] = (CGI.unescape(values[1])).downcase if values.length == 2 
          h
        }
      rescue NoMethodError => e
        params_prime = Hash.new
      end
      params_prime
    end
    
    def call
      #@env = env unless defined?(@env)
      env[:query] = self.params(env['QUERY_STRING'])
      env[:path] = self.uri(env['SCRIPT_NAME'])
      response
      resp = req_params
      status_code = resp[:status_code] || 200
      content_type = resp[:content_type] || "text/html"
      [status_code, {"Content-Type" => content_type}, [resp[:body]]]
    end
    
    def request(*args)
    end
  
    def response
     req_params[:body] = self.render
     #return @req_params
    end
  end
end