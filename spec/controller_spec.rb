LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'rack'
require File.join(File.dirname(__FILE__), '../lib/lamed/model')
require File.join(File.dirname(__FILE__), "../lib/lamed/helper")
require File.join(File.dirname(__FILE__), '../lib/lamed/controller')

include Lamed

module Lamed
  
  describe Controller do
    let(:controller) { Controller.new }
    let(:env) { { "GATEWAY_INTERFACE"=>"CGI/1.1", "PATH_INFO"=>"", "QUERY_STRING"=>"hello=test&foo=bar",
           "REMOTE_ADDR"=>"127.0.0.1", "REMOTE_HOST"=>"radio.local", "REQUEST_METHOD"=>"GET",
           "REQUEST_URI"=>"http://localhost:9292/hello_world?hello=test&foo=bar", "SCRIPT_NAME"=>"/hello_world",
           "SERVER_NAME"=>"localhost", "SERVER_PORT"=>"9292", "SERVER_PROTOCOL"=>"HTTP/1.1",
           "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/1.9.1/2009-12-07)", "HTTP_HOST"=>"localhost:9292",
           "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.7) Gecko/20091221 Firefox/3.5.7",
           "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "HTTP_ACCEPT_LANGUAGE"=>"en-us,en;q=0.5",
           "HTTP_ACCEPT_ENCODING"=>"gzip,deflate", "HTTP_ACCEPT_CHARSET"=>"UTF-8,*", "HTTP_KEEP_ALIVE"=>"300",
           "HTTP_CONNECTION"=>"keep-alive", "HTTP_CACHE_CONTROL"=>"max-age=0", "rack.version"=>[1, 0],
           "rack.multithread"=>true, "rack.multiprocess"=>false, "rack.run_once"=>false, "rack.url_scheme"=>"http",
           "HTTP_VERSION"=>"HTTP/1.1", "REQUEST_PATH"=>"/hello_world" } }
    
    before(:each) do
      controller.stub(:env).and_return(env)
    end
    
    it "request_params" do
      controller.req_params.should == {"GATEWAY_INTERFACE"=>"CGI/1.1", "PATH_INFO"=>"", "QUERY_STRING"=>"hello=test&foo=bar",
        "REMOTE_ADDR"=>"127.0.0.1", "REMOTE_HOST"=>"radio.local", "REQUEST_METHOD"=>"GET", "REQUEST_URI"=>"http://localhost:9292/hello_world?hello=test&foo=bar",
        "SCRIPT_NAME"=>"/hello_world", "SERVER_NAME"=>"localhost", "SERVER_PORT"=>"9292", "SERVER_PROTOCOL"=>"HTTP/1.1",
        "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/1.9.1/2009-12-07)", "HTTP_HOST"=>"localhost:9292",
        "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.7) Gecko/20091221 Firefox/3.5.7",
        "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "HTTP_ACCEPT_LANGUAGE"=>"en-us,en;q=0.5",
        "HTTP_ACCEPT_ENCODING"=>"gzip,deflate", "HTTP_ACCEPT_CHARSET"=>"UTF-8,*", "HTTP_KEEP_ALIVE"=>"300", "HTTP_CONNECTION"=>"keep-alive",
        "HTTP_CACHE_CONTROL"=>"max-age=0", "rack.version"=>[1, 0], "rack.multithread"=>true, "rack.multiprocess"=>false, "rack.run_once"=>false,
        "rack.url_scheme"=>"http", "HTTP_VERSION"=>"HTTP/1.1", "REQUEST_PATH"=>"/hello_world"}
    end
    
    it "should set content type" do
      controller.content_type('text/html').should == 'text/html'
    end
    
    it "should get user_agent" do
      controller.user_agent.should == 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.7) Gecko/20091221 Firefox/3.5.7'
    end
    
    it "get uri" do
      controller.uri(env["REQUEST_PATH"]).should == [:hello_world]
    end
    
    it "get params" do
      controller.params(env["QUERY_STRING"]).should == {:hello=>"test", :foo=>"bar"}
    end
    
    it "set path" do
      controller.self_path('/usr/pub').should == '/usr/pub'
    end
    
    before(:each) do
      controller.stub(:render).and_return('Hello World')
    end
    
    it "should return a response" do
        controller.response.should == 'Hello World'
    end
    
    it "Controller.call" do
      controller.call.should == [200, {"Content-Type"=>"text/html"}, ["Hello World"]]
    end
  end
end