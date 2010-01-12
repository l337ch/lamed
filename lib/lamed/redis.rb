require 'redis'
  
class Redis
  
  # Adding namespace or prefix keys to redis SET and GET request much like memcache.
  
  $SYS_OPTIONS = {} unless defined?($SYS_OPTIONS)
  
  REDIS_OPTIONS = {
    :host    =>  $SYS_OPTIONS[:redis_host]     || '127.0.0.1' ,
    :port    => ($SYS_OPTIONS[:redis_port]    || 6379).to_i,
    :db      => ($SYS_OPTIONS[:redis_db]      || 0).to_i,
    :timeout => ($SYS_OPTIONS[:redis_timeout] || 5).to_i,
  }
  
  def initialize(host, opts={})
    @host    = host           || REDIS_OPTIONS[:host]
    @port    = opts[:port]    || REDIS_OPTIONS[:port]
    @db      = opts[:db]      || REDIS_OPTIONS[:db]
    @timeout = opts[:timeout] || REDIS_OPTIONS[:timeout]
    $debug   = opts[:debug]
    connect_to_server
  end
  
end
