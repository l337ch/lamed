LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'time'
require 'lib/lamed/aws/aws'

include AWS
describe "Return time object in xmlschema format" do
  it "should return a time string in xml schema format" do
    time_xml.should == Time.now.utc.xmlschema
  end
end