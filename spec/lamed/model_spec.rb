LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'spec_helper'
require 'lib/lamed/model'

module Lamed
  describe Model do
    
    it "Model should exist" do
      Model.should == Lamed::Model
    end
    
    it "should have instance methods" do
      Model.instance_methods(false).should == []
    end
    
    it "should have methods" do
      Model.methods(false).should == []
    end
  end
  
  describe DM do
    
    let(:dm) { DM.new(:host => 'localhost') }
    
    it "should intialize DM" do
      #dm = DM.new(:host => 'localhost')
      dm.inspect.should =~ /Lamed/
    end
    
    it "should connect to the database with defaults" do
      dm.connect.inspect.should =~ /DataMapper::Adapters::MysqlAdapter/
    end
  end
  
  describe MySQL do
    
    it "should initialize DM"
  end
end