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
        @host = DEFAULT_HOST
        @path = queue_name.nil? ? "/" : get_http_path(queue_name)
      end
      
      # First step is to get the URL path for a SQS queue
 
      def get_http_path(queue_name)
        queue_url = ''
        action = 'ListQueues'
        params = {
          'QueueNamePrefix' => queue_name
        }
        params.merge!(default_params)
        req = "/?" + generate_query(action, params)
        res = Typhoeus::Request.get(@host + req)
        xml_doc = XML.parse res.body
        url = (xml_doc["ListQueuesResponse"]["ListQueuesResult"]["QueueUrl"])
        URI.parse(url).path
      end
      
      def url_path
        @path
      end
      
      def list_queues(prefix = nil)
        
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
          'Expires' => (expires),
          'Version' => API_VERSION
        }
      end
      
      def create_request(uri, query_string = nil)
      end
    end  
  end
end