LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

ENV['AMAZON_ACCESS_KEY_ID'] = 'THISISTHEACCESSKEYYO'
ENV['AMAZON_SECRET_ACCESS_KEY'] = 'THISISTHESECRETACCESSKEYYEAHBOISHOOBIDOO'

require 'lib/lamed/aws/aws'
require 'lib/lamed/aws/authentication'

include Aws::Authentication

describe Aws::Authentication do
  
  it "should get AWS access id, secret, and new digest from system" do
    aws_access_key_id.should == 'THISISTHEACCESSKEYYO'
    aws_secret_access_key.should == 'THISISTHESECRETACCESSKEYYEAHBOISHOOBIDOO'
    new_digest.inspect.should =~ /\#<OpenSSL::Digest::Digest:/
  end
  
  it "should escape string in an AWS friendly way" do
    string = 'Hello World. This:is:not-what-you-want'
    aws_escape(string).should == 'Hello%20World.%20This%3Ais%3Anot-what-you-want'
  end
  
  it "should escape params in an AWS friendly way" do
    hash = {
      'foo'     => 'Hello World',
      'foo:bar' => 'Rock-around-the-world'
    }
    aws_escape_params(hash).should == {"foo"=>"Hello%20World", "foo%3Abar"=>"Rock-around-the-world"}
  end
  
  it "should URI escape params" do
    hash = {
      'foo'     => 'Hello World',
      'foo:bar' => 'Rock-around-the-world'
    }
    uri_escape_params(hash, :ho => 'test').should == {"foo"=>"Hello%20World", "foo:bar"=>"Rock-around-the-world", "ho"=> "test"}
  end
  
  it "should generate the string to sign" do
    self.should_receive(:default_params).and_return("foo" => 'bar')
    uri = '/123456789012/exampleQueue'
    httpverb = "GET"
    host = 'queue.amazonaws.com'
    generate_string_to_sign(httpverb, host, uri, params = {}).should == ''
  end
  
  it "should generate the query using action ListQueues" do
    self.should_receive(:default_params).and_return("foo" => 'bar')
    self.should_receive(:url_path).and_return('/123456789012/exampleQueue')
    action = "ListQueues"
    params = { 'QueueNamePrefix' => 'exampleQueue' } 
    generate_query(action, params).should == ''
  end
  
end