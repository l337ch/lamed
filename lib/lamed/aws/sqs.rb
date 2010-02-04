module Aws
  module Sqs
    
    DEFAULT_HOST = URI.parse('http://queue.amazonaws.com/')
    API_VERSION = '2009-02-01'
    
    class Queue
      
      include Aws::Authentication
      
      REQUEST_TTL = 600
      
      def initialize(queue_name)
        @queue_name = queue_name
        @path = get_http_path(queue_name)
        @uri = DEFAULT_HOST
      end
      
      # Get the URL path for a SQS queue 
      def get_http_path(queue_name)
        action = 'ListQueues'
        params = {
          'QueueNamePrefix' => queue_name
        }
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
    end  
  end
end