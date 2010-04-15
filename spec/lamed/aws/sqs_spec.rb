#LAME_ROOT =  File.join(File.dirname(__FILE__), '..')
#ROOT = File.join(LAME_ROOT, "/spec/examples")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

                               
ENV['AMAZON_ACCESS_KEY_ID'] = 'THISISTHEACCESSKEYYO'
ENV['AMAZON_SECRET_ACCESS_KEY'] = 'THISISTHESECRETACCESSKEYYEAHBOISHOOBIDOO'
                                       
require 'lib/lamed/aws/aws'
require 'lib/lamed/aws/authentication'
require 'lib/lamed/aws/sqs'
require 'spec_helper.rb'

include Aws

describe Aws::Sqs::Queue do
end
=begin
  #it "should initialize a queue" do
  #  sqs = Sqs::Queue.new('prod_scs_completed_imports')
  #end
  
  before(:each) do
    @sqs = Sqs::Queue.new()
  end
  
  it "should generate a request hash" do
    @sqs.generate_request('ListQueues').should == {
                                                   "Action"           => "ListQueues",
                                                   "SignatureMethod"  => "HmacSHA256",
                                                   "AWSAccessKeyId"   => ENV['AMAZON_ACCESS_KEY_ID'],
                                                   "SignatureVersion" => "2",
                                                   "Expires"          => @sqs.expires,
                                                   "Version"          => "2009-02-01"
                                                   }
  end

  it "should generate the string that will be signed" do
    params = {
               "Action"           => "ListQueues",
               "SignatureMethod"  => "HmacSHA256",
               "AWSAccessKeyId"   => ENV['AMAZON_ACCESS_KEY_ID'],
               "SignatureVersion" => "2",
               "Expires"          => "2010-02-10T21:24:40Z",
               "Version"          => "2009-02-01"
               }
    @sqs.generate_string_to_sign(:get, 'queue.amazonaws.com', '/', params).should == "GET\nqueue.amazonaws.com\n/\nAWSAccessKeyId=" +
                                                                                    "THISISTHEACCESSKEYYO&Action=ListQueues&Expires=" + 
                                                                                    "2010-02-10T21%3A24%3A40Z&SignatureMethod=" + 
                                                                                    "HmacSHA256&SignatureVersion=2&Version=2009-02-01"
  end

  it "should generate a request signature" do
    string_to_sign = "GET\nqueue.amazonaws.com\n/\nAWSAccessKeyId=" +
                     "1NK7GFJZMZPXRPE6S802&Action=ListQueues&Expires=" + 
                     "2010-02-10T21%3A24%3A40Z&SignatureMethod=" + 
                     "HmacSHA256&SignatureVersion=2&Version=2009-02-01"
    @sqs.aws_signature(string_to_sign).should == 'UyAhOaBN7ye4GQ2lhgY3aYGUWy3Rb64S6Y6T/u/vb5o='
  end

  it "should generate a SQS query hash with queue list request" do
    @list_queue_query_string = @sqs.generate_query("ListQueues", 'QueueNamePrefix' => 'prod')
    @list_queue_query_string.should =~ /Action=ListQueues&SignatureMethod=HmacSHA256&AWSAccessKeyId=THISISTHEACCESSKEYYO&SignatureVersion=2&Expires=/
  end

  it "should create a new queue" do
    @sqs.create("test_scs_completed_imports").inspect.should =~ /CreateQueueResponse/
  end
  
  it "should list a queue's attribute" do
    @sqs.attributes.inspect.should =~ /GetQueueAttributesResponse/
  end
  
  it "should get a url path for a SQS queue" do
    @sqs.path.should == '/002611861940/test_scs_completed_imports'
  end
  
  it "should send a message" do
    msg = "This is a test"
    @sqs.send(msg).inspect.should =~ /SendMessageResponse/
  end
  
  it "should receive the test message" do
    @sqs.receive
    message = sqs.message
    @@receipt_handle = message["ReceiptHandle"]
    message.inspect.should =~ /MessageId/
  end
  
  it "should delete the message from the queue" do
    receipt_handle = @@receipt_handle
    @sqs.delete(receipt_handle).inspect.should =~ /DeleteMessageResponse/
  end
end
=end