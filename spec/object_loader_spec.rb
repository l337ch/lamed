LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/fixtures")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'mustache'
require 'rack'
require "lib/lamed/helper"
require 'lib/lamed/model'
require 'lib/lamed/controller'
require "lib/lamed/object_loader"

module Lamed
    
  describe "Load Objects into a tree" do
    it "should find all record files within a subdir" do
      record_result     = ["/usr/pub/projects/lamed/spec/../spec/fixtures/ext/model/bar_model.rb",
                           "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/model/foo_model.rb"]
      controller_result = ["/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/hello_world.rb",
                           "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/lamest/bar.rb",
                           "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/lamest/foo.rb"]
      record_paths = ObjectLoader.get_files(:model)
      controller_paths = ObjectLoader.get_files(:controller)
      record_paths.should == record_result
      controller_paths.should == controller_result
    end
  
    it "should group subdirs together given a path" do
      @paths = ["/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/hello_world.rb",
                    "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/lamest/foo.rb",
                    "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/lamest/bar.rb"]
      result = {"/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller"=>["hello_world.rb"],
                "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/lamest"=>["bar.rb", "foo.rb"]}
      mapped_file = ObjectLoader.map_file_to_subdir
      mapped_file.should == result
    end

    it "should get the camelized ext sub directory" do
      subdir = "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/second"
      ext_subdir = ObjectLoader.camelize_ext_subdir(subdir)
      ext_subdir.should == [:Controller, :Second]
    end
    
    it "should load path symbols as objects" do
      camelized_path = [:Controller, :Second]
      klass = ObjectLoader.create_object_from_camelized_path(camelized_path)
      klass.should == Lamed::Controller::Second
    end
    
    it "should create new Controller objects from files" do
      subdir, file_name = "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/lamest", 
                          ["bar.rb", "foo.rb"]                          
      new_objects = ObjectLoader.load_new_object(subdir, file_name)
      Object.constants.include?(:Foo).should == true
      Object.constants.include?(:Bar).should == true
      # Clean up
      Object.instance_eval { [:Foo, :Bar].each { |o| remove_const o } }
    end
    
    it "should create new Record Objects from files" do
      subdir, file_name = "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/model",
                          ["foo_model.rb", "bar_model.rb"]
      new_objects = ObjectLoader.load_new_object(subdir, file_name)
      Object.constants.include?(:FooModel).should == true
      Object.constants.include?(:BarModel).should == true
      # Clean up
       Object.instance_eval { [:BarModel, :FooModel].each { |o| remove_const o } }
    end
    
    it "should create a new view path for the new class" do
      camelized_ext_subdir = [:Controller, :Second]
      view_path = ObjectLoader.create_view_path(camelized_ext_subdir)
      view_path.should == "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/view/second"
    end
      
    it "should move new objects to new Lamed class/modules" do
      load 'lib/lamed/object_loader.rb'
      subdir, file_name = "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/lamest",
                          ["bar.rb", "foo.rb"]
      ObjectLoader.load_controller_into_new_class(subdir, file_name)
      Object::Lamed::Controller::Lamest.constants.should == [:Bar, :Foo]
      Object::Lamed::Controller::Lamest::Foo.class.should == Class
    end
    
    it "should check to see if new objects were removed from Object" do
      Object.constants.include?(:SecondController).should == false
      Object.constants.include?(:ThirdController).should == false
    end
    
    it "should check the view path for the new objects" do
      Object::Lamed::Controller::Lamest::Bar.path.should == "/usr/pub/projects/lamed/spec/fixtures/ext/view/lamest"
      Object::Lamed::Controller::Lamest::Foo.path.should == "/usr/pub/projects/lamed/spec/fixtures/ext/view/lamest"
    end
    
    it "should load up controllers" do
      ObjectLoader.load_controller_object
      Lamed.constants.should == [:Helper, :Model, :MySQL, :Controller, :ObjectLoader]
      Lamed::Controller.constants.sort.should == [:Adapter, :Auth, :Builder, :Cascade, :Chunked, :CommonLogger,
                                                  :ConditionalGet, :ContentLength, :ContentType, :Context, :ContextMiss,
                                                  :Deflater, :Directory, :File, :ForwardRequest, :Handler, :Head, 
                                                  :HelloWorld, :Lamest, :Lint, :Lock, :MethodOverride, :Mime, :MockRequest,
                                                  :MockResponse, :Recursive, :Reloader, :Request, :Response, :Second,
                                                  :Session, :ShowExceptions, :ShowStatus, :Static, :Template, :URLMap,
                                                  :Utils, :VERSION].sort
      Lamed::Controller::Lamest.constants.should == [:Bar, :Foo]
    end
    
    it "should load up models" do
      ObjectLoader.load_model_object
      Lamed.constants.should == [:Helper, :Model, :MySQL, :Controller, :ObjectLoader]
      Lamed::Model.constants.should == [:BarModel, :FooModel]
    end
    
  end
  
end