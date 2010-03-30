LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'rack'
require 'lib/lamed/initializer'

  
describe "Initialize all Lamed Objects" do
  it "should initialize the logger to STDERR" do
    Lamed.logger.level.should == 0
  end
  
  it "should initialize options to opts" do
    Lamed.opts.should == {:main_cache=>["127.0.0.1:11211"], :redis_host=>"127.0.0.1", :redis_port=>6389, :http_procs=>1,
                          :workers=>1, :port=>3000, :run_as=>"reco", :pid=>"/var/run/", :logs=>"/var/log/nutsie_radio",
                          :rotate=>"daily"}
  end
  
  it "should initialize the Controller, Lib, and Model objects" do
    Lamed::Model.constants.should == [:BarModel, :FooModel]
    Lamed::Controller.constants.sort.should == [:HelloWorld, :Lamest, :BarModel, :FooModel, :VERSION, :Cascade, :Chunked,
                                           :ConditionalGet, :ContentLength, :ContentType, :File, :Deflater, :Directory,
                                           :ForwardRequest, :Handler, :Head, :Lint, :Lock, :MethodOverride, :Mime,
                                           :Recursive, :Reloader, :ShowStatus, :Static, :URLMap, :MockRequest,
                                           :MockResponse, :Response, :Auth, :Session, :Adapter, :Builder, :CommonLogger,
                                           :Utils, :Request, :ShowExceptions, :Template, :ContextMiss, :Context].sort
    Object.constants.include?(:FooLib).should == true
  end
  
end