LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

ENV['AMAZON_ACCESS_KEY_ID'] = 'pass_me'
ENV['AMAZON_SECRET_ACCESS_KEY'] = 'pass_me'

require 'lib/lamed/aws/aws'
require 'lib/lamed/aws/authentication'

include Aws::Authentication

describe "Safe AWS escape" do
  it "should escape string in an AWS friendly way" do
    string = 'Hello World.  This:is:not-what-you-want'
    aws_escape(string).should == 'Hello%20World.%2020This%3Ais%3Anot%2Dwhat%2Dyou%2Dwant'
  end
  
  it "should escape params in an AWS friendly way" do
    hash = {
      'foo'     => 'Hello World',
      'foo:bar' => 'Rock-around-the-world'
    }
    aws_escape_params(hash).should == {"foo"=>"Hello%20World", "foo%3Abar"=>"Rock%2Daround%2Dthe%2Dworld"}
  end
end

describe "Login into Amazon AWS" do
  it "should get AWS access id and secret from system ENV" do
    aws_access_key_id.should == 'pass_me'
    aws_secret_access_key.should == 'pass_me'
    new_digest.inspect.should == "#<OpenSSL::Digest::Digest: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855>"
  end
end