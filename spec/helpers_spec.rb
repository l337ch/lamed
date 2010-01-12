require File.join(File.dirname(__FILE__), "spec_helper")
require File.join(File.dirname(__FILE__), '..', '/lib/lamed/helper')

module Lamed
  
  include Helper
  describe "Symbolize Hash Keys" do
    it "should convert hash keys from strings to symbols" do
      hash = { 'key1' => 1, 'key2' => { 'key3' => 3, 'key4' => 4 } }
      symbolized_hash = symbolize_hash_keys hash
      symbolized_hash.should == { :key1 => 1, :key2 => { :key3 => 3, :key4 => 4 } }
    end
  end

  describe "Camelize a string seperated by _" do
    it "should convert strings seperated by _ in a single cameled word" do
      string = "foo_bar"
      cameled_string = camelize_string string
      cameled_string.should == "FooBar"
    end
  
    it "should uncamelize a cameled string into an uncameled _ seperated string" do
      string = "FooBar"
      uncameled_string = uncamelize_string string
      uncameled_string.should == "foo_bar"
    end
  end

  describe "Camelize a path" do
    it "should convert a path into a single cameled symbols" do
      path = "/foo/bar"
      cameled_path = camelize_path path
      cameled_path.should == [:Foo, :Bar]
    end
  
    it "should convert an array of camelized symbols to a path" do
      camelized_path = [:Foo, :Bar, :HootBar]
      uncamelized_path = uncamelize_path camelized_path
      uncamelized_path.should == '/foo/bar/hoot_bar'
    end
  end

  describe "Convert a string into a time object" do
    it "should convert a date string into a time object" do
      string = "2009-01-01 00:00:00"
      date = mysql_time string
      date.to_i.should == 1230796800
    end
  end
  
end