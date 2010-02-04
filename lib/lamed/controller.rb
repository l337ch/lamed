require 'mustache'

module Lamed
  class Controller < Mustache
    
    include Rack
    include Lamed::Helper
    extend Lamed::Helper
    include Lamed::Model
              
    attr_accessor :query, :path, :self_path, :env
    
    def set_self_path(str)
      @self_path = str
    end
  
    def parse_uri(request_path)
      begin
        uri = (request_path.split("/").collect {|r| r.downcase.intern unless r.empty?}).compact
      rescue NoMethodError
        uri = Array.new
      end
      @uri = uri
    end

    def parse_query_string(query_string)
      begin
        params = query_string.split('&').inject({}) { |h,(k,v)|
          values = k.split('=')
          # Drop any query params that have blank values
          h[values[0].downcase.intern] = (CGI.unescape(values[1])).downcase if values.length == 2 
          h
        }
      rescue NoMethodError => e
        params = Hash.new
      end
      @params = params
    end
    
    def params
      @params
    end
    
    def call(env)
      @env = env unless defined?(@env)
      env[:query] = self.parse_query_string(env['QUERY_STRING'])
      env[:path] = self.parse_uri(env['SCRIPT_NAME'])
      response(env)
      resp = @req_params
      status_code = resp[:status_code] || 200
      content_type = resp[:content_type] || "text/html"
      [status_code, {"Content-Type" => content_type}, [resp[:body]]]
    end
    
    def env
      @env
    end
    
    def request(*args)
    end
  
    def response(env)
     @req_params = env
     @req_params[:body] = self.render
     return @req_params
    end
  
    def content_type(content_type)
      @req_params[:content_type] = content_type
    end
    
    def user_agent
      @env['HTTP_USER_AGENT']
    end
  end
end