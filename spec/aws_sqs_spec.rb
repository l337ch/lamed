LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))


ENV['AMAZON_ACCESS_KEY_ID'] = '1NK7GFJZMZPXRPE6S802'
ENV['AMAZON_SECRET_ACCESS_KEY'] = 'Qq97jbMRfHK6zGns8RmT5nRTdHVbKmc7CNBWHexl'

require 'lib/lamed/aws/aws'
require 'lib/lamed/aws/authentication'
require 'lib/lamed/aws/sqs'

include Aws

describe "Log into AWS SQS" do
  it "should initialize a queue" do
    sqs = Aws::Sqs::Queue.new('test')
  end
  
  it "should generate a request hash" do
    sqs = Sqs::Queue.new('test')
    sqs.generate_request('Get').should == {"Action"=>"Get", "SignatureMethod"=>"HmacSHA256", "AWSAccessKeyId"=>'pass_me',
                                            "SignatureVersion"=>"2", "Expires"=>60, "Version"=>"2009-02-01"}
  end
  
  it "should generate a request signature" do
    sqs = Sqs::Queue.new('test')
    params = sqs.generate_request('Get')
    sqs.aws_signature(params, 'GET', 'queue.amazonaws.com', '').should ==
                                                                '2bfq0e%2FkOnq1Rm6iT4S%2BPEJXfTABSBMZtTu1UmgXmVY%3D'
  end
  
  it "should generate a SQS query string with queue list request" do
    sqs = Aws::Sqs::Queue.new('')
    sqs.get_query_string('ListQueues', 'QueueNamePrefix' => 'prod').should == ''
  end
  
end