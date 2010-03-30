LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
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
    
    it "should intialize DM" do
      dm = DM.new(:host => 'localhost')
      dm.instance_variables.should == []
    end
  end
end