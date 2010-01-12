module Lamed
  
  class Controller < Mustache
    
    include Rack
    include Lamed::Helper
    extend Lamed::Helper
    include Lamed::Record
    include Lamed::Lib
              
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
      return uri
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
      return params
    end
  
    def call(env)
      env[:query] = self.parse_query_string(env['QUERY_STRING'])
      env[:path] = self.parse_uri(env['SCRIPT_NAME'])
      response(env)
      resp = @req_params
      status_code = resp[:status_code] || 200
      content_type = resp[:content_type] || "text/html"
      [status_code, {"Content-Type" => content_type}, [resp[:body]]]
    end

    def request(*args)
    end
  
    def response(req_params)
     @req_params = req_params
     @req_params[:body] = self.render
     return @req_params
    end
  
    def content_type(string)
      @req_params[:content_type] = string
    end
  
  end
    
end