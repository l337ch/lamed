module Aws
  module Sqs
    
    DEFAULT_HOST = 'queue.amazonaws.com'
    API_VERSION = '2009-02-01'
    
    class Queue
      
      include Aws::Authentication
      include Aws
      include Crack
      
      REQUEST_TTL = 600
      
      attr_reader :host, :path, :expires
      
      def initialize(queue_name = nil)
        @host       = DEFAULT_HOST
        @queue_name = queue_name
        @path = queue_name.nil? ? "/" : get_http_path if @path.nil?
      end
 
      def get_http_path
        action = 'ListQueues'
        params = { "QueueNamePrefix" => @queue_name }.merge(default_params)
        path = url_path || ""
        xml_doc = http_get_xml(@host, path, generate_query(action, params))
        url = (xml_doc["ListQueuesResponse"]["ListQueuesResult"]["QueueUrl"])
        url = url[0] if Array === url
        URI.parse(url).path
      end
      
      def url_path
        @path
      end
      
      # List all the queues that start with the prefix.
      def list_queues(prefix = "")
        action = "ListQueues"
        @path = "/"
        available_queues = Array.new
        xml_doc = http_get_xml(@host, path, generate_query(action, default_params))
        if xml_doc["ListQueuesResponse"]["ListQueuesResult"]["QueueUrl"]
          xml_doc["ListQueuesResponse"]["ListQueuesResult"]["QueueUrl"].each do |url|
            available_queues << url.split("/").last
          end
        end
        available_queues
      end
      
      def attributes
        action = "GetQueueAttributes"
        params = { "AttributeName" =>"All" }.merge(default_params)
        http_get_xml(@host, @path, generate_query(action, params))
      end
      
      def create(queue_name)
        action = "CreateQueue"
        params = { "QueueName" => queue_name}
        params.merge!(default_params)
        @path = "/"
        http_get_xml(@host, @path, generate_query(action, params))
      end
      
      def send(message, send_params = nil)
        action = "SendMessage"
        params = { "MessageBody" => message }.merge(default_params)
        http_get_xml(@host, url_path, generate_query(action, params))
      end
      
      def receive(receive_params = {})
        action = "ReceiveMessage"
        params = { 
                  "MaxNumberOfMessages" => receive_params[:number] || 1,
                  "AttributeName"       => "All" }
        params["VisibilityTimeout"] = receive_params[:timeout] if receive_params[:timeout]
        params.merge!(default_params)
        xml = http_get_xml(@host, url_path, generate_query(action, params))
        
        if !xml["ReceiveMessageResponse"]["ReceiveMessageResult"].nil?
          message = xml["ReceiveMessageResponse"]["ReceiveMessageResult"]["Message"]
          @message_body = message["Body"]
          @message_attribute = message["Attribute"]
          @receipt_handle = message["ReceiptHandle"]
          @message = message
        else
          nil
        end
      end
      
      def receipt_handle
        @receipt_handle
      end
      
      def message
        @message
      end
      
      def message_body
        @message_body
      end
      
      def message_attributes
        @message_attribute
      end
      
      def delete(receipt_handle)
        action = "DeleteMessage"
        #unescaped_handle = URI.unescape(receipt_handle)
        params = { "ReceiptHandle" => receipt_handle }.merge(default_params)
        http_get_xml(@host, url_path, generate_query(action, params))
      end
      
      def delete_queue
        action = "DeleteQueue"
        params = default_params
        http_get_xml(@host, url_path, generate_query(action, params))
      end
      
      # +time+ is expressed as a string.
      def expires(time = nil)
        if !time
          (Time.now.utc + REQUEST_TTL).xmlschema
        else
          (Time.parse(time) + REQUEST_TTL).xmlschema
        end
      end
      
      def default_params
        request = {
          'Expires' => expires,
          'Version' => API_VERSION
        }
      end
      
      def create_request(uri, query_string = nil)
      end
    end  
  end
end