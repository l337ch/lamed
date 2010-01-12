LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/fixtures")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'mustache'
require 'rack'
require "lib/lamed/helper"
require 'lib/lamed/lib'
require 'lib/lamed/record'
require 'lib/lamed/controller'
require "lib/lamed/object_loader"

module Lamed
    
  describe "Load Objects into a tree" do
    it "should find all record files within a subdir" do
      record_result     = ["/usr/pub/projects/lamed/spec/../spec/fixtures/ext/record/bar_record.rb",
                           "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/record/foo_record.rb"]
      controller_result = ["/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/first_controller.rb",
                           "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/second/second_controller.rb", 
                           "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/second/third_controller.rb"]
      record_paths = ObjectLoader.get_files(:record)
      controller_paths = ObjectLoader.get_files(:controller)
      record_paths.should == record_result
      controller_paths.should == controller_result
    end
  
    it "should group subdirs together given a path" do
      @paths = ["/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/first_controller.rb",
                    "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/second/second_controller.rb",
                    "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/second/third_controller.rb"]
      result = { "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller" => ["first_controller.rb"],
                 "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/second" => ["second_controller.rb",
                 "third_controller.rb"] }
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
      subdir, file_name = "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/second", 
                          ["second_controller.rb", "third_controller.rb"]                          
      new_objects = ObjectLoader.load_new_object(subdir, file_name)
      Object.constants.include?(:SecondController).should == true
      Object.constants.include?(:ThirdController).should == true
      # Clean up
      Object.instance_eval { [:SecondController, :ThirdController].each { |o| remove_const o } }
    end
    
    it "should create new Record Objects from files" do
      subdir, file_name = "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/record",
                          ["foo_record.rb", "bar_record.rb"]
      new_objects = ObjectLoader.load_new_object(subdir, file_name)
      Object.constants.include?(:FooRecord).should == true
      Object.constants.include?(:BarRecord).should == true
      # Clean up
       Object.instance_eval { [:BarRecord, :FooRecord].each { |o| remove_const o } }
    end
    
    it "should create a new view path for the new class" do
      camelized_ext_subdir = [:Controller, :Second]
      view_path = ObjectLoader.create_view_path(camelized_ext_subdir)
      view_path.should == "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/view/second"
    end
      
    it "should move new objects to new Lamed class/modules" do
      load 'lib/lamed/object_loader.rb'
      subdir, file_name = "/usr/pub/projects/lamed/spec/../spec/fixtures/ext/controller/second",
                          ["second_controller.rb", "third_controller.rb"]
      ObjectLoader.load_new_object_into_klass(subdir, file_name)
      Object::Lamed::Controller::Second.constants.should == [:SecondController, :ThirdController]
      Object::Lamed::Controller::Second::ThirdController.class.should == Class
    end
    
    it "should check to see if new objects were removed from Object" do
      Object.constants.include?(:SecondController).should == false
      Object.constants.include?(:ThirdController).should == false
    end
    
    it "should check the view path for the new objects" do
      Object::Lamed::Controller::Second::SecondController.path.should == "/usr/pub/projects/lamed/spec/fixtures/ext/view/second"
      Object::Lamed::Controller::Second::ThirdController.path.should == "/usr/pub/projects/lamed/spec/fixtures/ext/view/second"
    end
    
    it "should load up controllers" do
      ObjectLoader.load_new_objects(:controller)
      Lamed.constants.should == [:Helper, :Lib, :Record, :Controller, :ObjectLoader]
      Lamed::Controller.constants.should == [:Second, :FirstController, :VERSION, :Builder, :Cascade, :Chunked, :CommonLogger,
                                            :ConditionalGet, :ContentLength, :ContentType, :File, :Deflater, :Directory,
                                            :ForwardRequest, :Handler, :Head, :Lint, :Lock, :MethodOverride, :Mime,
                                            :Recursive, :Reloader, :ShowExceptions, :ShowStatus, :Static, :URLMap, :Utils,
                                            :MockRequest, :MockResponse, :Request, :Response, :Auth, :Session, :Adapter,
                                            :Template, :ContextMiss, :Context]
      Lamed::Controller::Second.constants.should == [:SecondController, :ThirdController]
    end
    
    it "should load up records" do
      ObjectLoader.load_new_objects(:record)
      Lamed.constants.should == [:Helper, :Lib, :Record, :Controller, :ObjectLoader]
      Lamed::Record.constants.should == [:BarRecord, :FooRecord]
    end
    
  end
  
end