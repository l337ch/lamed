LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/fixtures")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'rack'
require 'lib/lamed/initializer'

module Lamed
  
  describe "Initialize all Lamed Objects" do
    it "should initialize the logger to STDERR" do
      Lamed.logger.level.should == 0
    end
    
    it "should initialize the Controller and Record objects" do
      Lamed::Record.constants.should == [:BarRecord, :FooRecord]
      Lamed::Controller.constants.should == [:FirstController, :Second, :BarRecord, :FooRecord, :VERSION, :Builder, :Cascade,
                                            :Chunked, :CommonLogger, :ConditionalGet, :ContentLength, :ContentType, :File,
                                            :Deflater, :Directory, :ForwardRequest, :Handler, :Head, :Lint, :Lock,
                                            :MethodOverride, :Mime, :Recursive, :Reloader, :ShowExceptions, :ShowStatus,
                                            :Static, :URLMap, :Utils, :MockRequest, :MockResponse, :Request, :Response, :Auth,
                                            :Session, :Adapter, :Template, :ContextMiss, :Context]
    end
    
  end
  
end